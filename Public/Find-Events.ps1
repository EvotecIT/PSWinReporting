function Find-Events {
    [CmdLetBinding(DefaultParameterSetName = 'Manual')]
    param(
        [parameter(ParameterSetName = "DateManual")]
        [parameter(ParameterSetName = "Manual", Mandatory = $true)][DateTime] $DateFrom,
        [parameter(ParameterSetName = "DateManual")]
        [parameter(ParameterSetName = "Manual", Mandatory = $true)][DateTime] $DateTo,
        [parameter(ParameterSetName = "Manual")]
        [parameter(ParameterSetName = "DateManual")]
        [parameter(ParameterSetName = "DateRange", Mandatory = $true)][alias('Server', 'ComputerName')][string[]] $Servers = $Env:COMPUTERNAME,
        [parameter(ParameterSetName = "Manual")]
        [parameter(ParameterSetName = "DateManual")]
        [parameter(ParameterSetName = "DateRange", Mandatory = $true)][alias('RunAgainstDC')][switch] $DetectDC,
        [parameter(ParameterSetName = "Manual")]
        [parameter(ParameterSetName = "DateManual")]
        [parameter(ParameterSetName = "DateRange")][switch] $Quiet,
        [parameter(ParameterSetName = "Manual")]
        [parameter(ParameterSetName = "DateManual")]
        [parameter(ParameterSetName = "DateRange")][System.Collections.IDictionary] $LoggerParameters,
        [parameter(ParameterSetName = "Manual")]
        [parameter(ParameterSetName = "DateManual")]
        [parameter(ParameterSetName = "DateRange")][switch] $ExtentedOutput,
        [parameter(ParameterSetName = "Extended", Mandatory = $true)][System.Collections.IDictionary] $Definitions,
        [parameter(ParameterSetName = "Extended", Mandatory = $true)][System.Collections.IDictionary] $Times,
        [parameter(ParameterSetName = "Extended", Mandatory = $true)][System.Collections.IDictionary] $Target
    )
    DynamicParam {
        # Defines Report / Dates Range dynamically from HashTables and saved files
        $ParameterSetsAttributesDateManual = New-Object System.Management.Automation.ParameterAttribute
        $ParameterSetsAttributesDateManual.Mandatory = $true
        $ParameterSetsAttributesDateManual.ParameterSetName = 'DateManual'

        $ParamAttribDatesRange = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttribDatesRange.Mandatory = $true
        $ParamAttribDatesRange.ParameterSetName = 'DateRange'

        $ParameterSetsAttributes = New-Object System.Management.Automation.ParameterAttribute
        $ParameterSetsAttributes.Mandatory = $true
        $ParameterSetsAttributes.ParameterSetName = 'Manual'

        # Definitions for Report
        $Names = (Get-EventsDefinitions).Keys
        $ReportAttrib = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $ReportAttrib.Add($ParameterSetsAttributes)
        $ReportAttrib.Add($ParamAttribDatesRange)
        $ReportAttrib.Add($ParameterSetsAttributesDateManual)
        $ReportAttrib.Add((New-Object System.Management.Automation.ValidateSetAttribute($Names)))
        $ReportRuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Report', [string[]], $ReportAttrib)

        # Definitions for Dates Range
        $DatesRange = $Script:ReportTimes.Keys
        $DatesRangeAttrib = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $DatesRangeAttrib.Add($ParamAttribDatesRange)
        $DatesRangeAttrib.Add((New-Object System.Management.Automation.ValidateSetAttribute($DatesRange)))
        $DatesRangeRuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DatesRange', [string], $DatesRangeAttrib)

        # Finalization
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('Report', $ReportRuntimeParam)
        $RuntimeParamDic.Add('DatesRange', $DatesRangeRuntimeParam)
        return $RuntimeParamDic
    }
    Process {
        $ExecutionTime = Start-TimeLog
        ## Logging / Display to screen
        if (-not $LoggerParameters) {
            $LoggerParameters = $Script:LoggerParameters
        }
        $Logger = Get-Logger @LoggerParameters

        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }

        if ($null -ne $Definitions -and $null -ne $Times -and $null -ne $Target) {
            # Using in case of Extendted Input - Mateusz asked for it.
            $Dates = Get-ChoosenDates -ReportTimes $Times
        } elseif ($null -ne $Definitions -or $null -ne $Times -or $null -ne $Target) {
            $Logger.AddErrorRecord('Wrong parameter choice.')
        } else {
            # Using standard case
            $Reports = $PSBoundParameters.Report
            $DatesRange = $PSBoundParameters.DatesRange

            $Logger.AddInfoRecord("Preparing reports: $($Reports -join ',')")

            # Bring defaults
            $Definitions = $Script:ReportDefinitions

            # Set Times
            $Times = $Script:ReportTimes
            switch ($PSCmdlet.ParameterSetName) {
                DateRange {
                    $Times.$DatesRange.Enabled = $true
                }
                DateManual {
                    if ($DateFrom -and $DateTo) {
                        $Times.CustomDate.Enabled = $true
                        $Times.CustomDate.DateFrom = $DateFrom
                        $Times.CustomDate.DateTo = $DateTo
                    } else {
                        return
                    }
                }
            }

            # Fixes ReportTimes
            $Dates = Get-ChoosenDates -ReportTimes $Times
            # Fixes Definitions
            foreach ($Report in $Reports) {
                $Definitions[$Report].Enabled = $true
            }

            $Target = New-TargetServers -Servers $Servers -UseDC:$DetectDC
        }

        # Real deal
        [Array] $ExtendedInput = Get-ServersList -Definitions $Definitions -Target $Target -Dates $Dates
        foreach ($Entry in $ExtendedInput) {
            if ($Entry.Type -eq 'Computer') {
                if (-not $Quiet) { $Logger.AddInfoRecord("Computer $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')") }
            } else {
                if (-not $Quiet) { $Logger.AddInfoRecord("File $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')") }
            }
        }
        if (-not $Quiet) { $Logger.AddInfoRecord("Getting events for dates $($Dates.DateFrom) to $($Dates.DateTo)") }
        #$ElapsedMiddle = Stop-TimeLog -Time $ExecutionTime -Option OneLiner -Continue
        #if (-not $Quiet) { $Logger.AddInfoRecord("Preparation - Time elapsed: $ElapsedMiddle") }
        # Scan all events and get everything at once
        [Array] $AllEvents = Get-Events -ExtendedInput $ExtendedInput -ErrorAction SilentlyContinue -ErrorVariable AllErrors -Verbose:$Verbose

        foreach ($MyError in $AllErrors) {
            if (-not $Quiet) { $Logger.AddErrorRecord("Server $MyError") }
        }
        $Elapsed = Stop-TimeLog -Time $ExecutionTime -Option OneLiner
        if (-not $Quiet) { $Logger.AddInfoRecord("Events scanned found $($AllEvents.Count) - Time elapsed: $Elapsed") }

        $Results = Get-EventsOutput -Definitions $Definitions -AllEvents $AllEvents -Quiet:$Quiet
        if ((Get-ObjectCount -Object $Reports) -eq 1) {
            # if there is only one report to return, return Array
            $Results[$Reports]
        } else {
            # If there is more than one, return hashtable
            $Results
        }
        # This prevents duplication of reports on second script run
        foreach ($Report in $Script:ReportDefinitions.Keys) {
            $Script:ReportDefinitions[$Report].Enabled = $false
        }
    }
}
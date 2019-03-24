function Find-Events {
    [CmdLetBinding()]
    param(
        [parameter(ParameterSetName = "DateManual")][DateTime] $DateFrom,
        [parameter(ParameterSetName = "DateManual")][DateTime] $DateTo,
        [alias('Server', 'ComputerName')][string[]] $Servers = $Env:COMPUTERNAME,
        [alias('RunAgainstDC')][switch] $DetectDC,
        [switch] $Quiet,
        [System.Collections.IDictionary] $LoggerParameters,
        [switch] $ExtentedOutput
    )
    DynamicParam {
        # Defines Report / Dates Range dynamically from HashTables
        $Names = $Script:ReportDefinitions.Keys
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory = $true
        $ParamAttrib.ParameterSetName = '__AllParameterSets'

        $ReportAttrib = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $ReportAttrib.Add($ParamAttrib)
        $ReportAttrib.Add((New-Object System.Management.Automation.ValidateSetAttribute($Names)))
        $ReportRuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Report', [string[]], $ReportAttrib)

        $DatesRange = $Script:ReportTimes.Keys
        $ParamAttribDatesRange = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttribDatesRange.Mandatory = $true
        $ParamAttribDatesRange.ParameterSetName = 'DateRange'
        $DatesRangeAttrib = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $DatesRangeAttrib.Add($ParamAttribDatesRange)
        $DatesRangeAttrib.Add((New-Object System.Management.Automation.ValidateSetAttribute($DatesRange)))
        $DatesRangeRuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DatesRange', [string], $DatesRangeAttrib)

        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('Report', $ReportRuntimeParam)
        $RuntimeParamDic.Add('DatesRange', $DatesRangeRuntimeParam)
        return $RuntimeParamDic
    }

    Process {
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }

        $Reports = $PSBoundParameters.Report
        $DatesRange = $PSBoundParameters.DatesRange

        # Bring defaults
        $Times = $Script:ReportTimes
        $Definitions = $Script:ReportDefinitions

        ## Logging / Display to screen

        if (-not $LoggerParameters) {
            $LoggerParameters = $Script:LoggerParameters
        }
        $Logger = Get-Logger @LoggerParameters

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
        # foreach ($Date in $Dates) {
        # Fixes Definitions
        foreach ($Report in $Reports) {
            $Definitions[$Report].Enabled = $true
        }

        $Target = New-TargetServers -Servers $Servers -UseDC:$DetectDC
        [Array] $ExtendedInput = Get-ServersList -Definitions $Definitions -Target $Target -Dates $Dates
        foreach ($Entry in $ExtendedInput) {
            if ($Entry.Type -eq 'Computer') {
                if (-not $Quiet) { $Logger.AddInfoRecord("Computer $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')") }
            } else {
                if (-not $Quiet) { $Logger.AddInfoRecord("File $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')") }
            }
        }

        $ExecutionTime = Start-TimeLog

        if (-not $Quiet) { $Logger.AddInfoRecord("Getting events for dates $($Dates.DateFrom) to $($Dates.DateTo)") }

        # Scan all events and get everything at once
        $AllEvents = Get-Events -ExtendedInput $ExtendedInput -ErrorAction SilentlyContinue -ErrorVariable AllErrors -Verbose:$Verbose

        foreach ($MyError in $AllErrors) {
            if (-not $Quiet) { $Logger.AddErrorRecord("Server $MyError") }
        }
        $Elapsed = Stop-TimeLog -Time $ExecutionTime -Option OneLiner
        if (-not $Quiet) { $Logger.AddInfoRecord("Events scanned found $(Get-ObjectCount -Object $AllEvents) - Time elapsed: $Elapsed") }

        $Results = Get-EventsOutput -Definitions $Definitions -AllEvents $AllEvents -Quiet:$Quiet
        if ((Get-ObjectCount -Object $Reports) -eq 1) {
            # if there is only one report to return, return Array
            $Results[$Reports]
        } else {
            # If there is more than one, return hashtable
            $Results
        }
    }
}
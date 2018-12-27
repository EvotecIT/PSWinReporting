function Find-ADEvents {
    [CmdLetBinding()]
    param(
        [parameter(ParameterSetName = "DateManual")]
        [DateTime] $DateFrom,

        [parameter(ParameterSetName = "DateManual")]
        [DateTime] $DateTo,

        [alias('Server', 'ComputerName')][string[]] $Servers,

        [System.Collections.IDictionary] $LoggerParameters
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
        $ReportRuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Report', [string], $ReportAttrib)

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

        $Report = $PSBoundParameters.Report
        $DatesRange = $PSBoundParameters.DatesRange

        # Bring defaults
        $ReportTimes = $Script:ReportTimes
        $ReportDefinitions = $Script:ReportDefinitions

        ## Logging / Display to screen

        if (-not $LoggerParameters) {
            $LoggerParameters = $Script:LoggerParameters
        }
        $Logger = Get-Logger @LoggerParameters

        ##
        if (-not $Servers) {
            $ServersAD = Get-DC
            $Servers = ($ServersAD | Where-Object { $_.'Host Name' -ne 'N/A' }).'Host Name'
        }

        switch ($PSCmdlet.ParameterSetName) {
            DateRange {
                $ReportTimes.$DatesRange.Enabled = $true
            }
            DateManual {
                if ($DateFrom -and $DateTo) {
                    $ReportTimes.CustomDate.Enabled = $true
                    $ReportTimes.CustomDate.DateFrom = $DateFrom
                    $ReportTimes.CustomDate.DateTo = $DateTo
                } else {
                    return
                }
            }
        }
        [string] $ReportNameTitle = Format-AddSpaceToSentence -Text $Report
        $Logger.AddInfoRecord("Report name: $ReportNameTitle")
        $Events = New-ArrayList
        $Dates = Get-ChoosenDates -ReportTimes $ReportTimes

        $MyReport = $ReportDefinitions[$Report]
        $LogNames = foreach ($SubReport in  $MyReport.Keys | Where-Object { $_ -ne 'Enabled' }) {
            $MyReport[$SubReport].LogName
        }
        $LogNames = $LogNames | Sort-Object -Unique


        foreach ($Log in $LogNames) {
            $EventsID = foreach ($R in $MyReport.Values) {
                if ($Log -eq $R.LogName) {
                    $R.Events
                    $Logger.AddInfoRecord("Events scanning for Events ID: $($R.Events) ($Log)")
                }
            }
            foreach ($Date in $Dates) {
                $ExecutionTime = Start-TimeLog
                $Logger.AddInfoRecord("Getting events for dates $($Date.DateFrom) to $($Date.DateTo)")
                $FoundEvents = Get-Events -Server $Servers -LogName $Log -EventID $EventsID -DateFrom $Date.DateFrom -DateTo $Date.DateTo -Verbose:$Verbose
                #$Logger.AddInfoRecord("Events: $EventsID Event Count: $($FoundEvents.Count)")
                Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
                $Elapsed = Stop-TimeLog -Time $ExecutionTime -Option OneLiner
                $Logger.AddInfoRecord("Events scanned found $(Get-ObjectCount -Object $FoundEvents) - Time elapsed: $Elapsed")
            }
        }
        return Get-MyEvents -Events $Events -ReportDefinition $MyReport -ReportName $Report
    }
}
function Get-MyEvents {
    [CmdLetBinding()]
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $ReportDefinition,
        [switch] $Quiet
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

        $ReportRuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ReportName', [string], $ReportAttrib)

        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('ReportName', $ReportRuntimeParam)
        return $RuntimeParamDic
    }
    Process {
        [string] $ReportName = $PSBoundParameters.ReportName
        [string] $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName
        if (-not $Quiet) { $Logger.AddInfoRecord("Running beautification process, applying filters for $ReportNameTitle report.") }
        $ExecutionTime = Start-TimeLog

        foreach ($Report in $ReportDefinition.Keys | Where-Object { $_ -ne 'Enabled' }) {
            $EventsType = $ReportDefinition[$Report].LogName
            $EventsNeeded = $ReportDefinition[$Report].Events
            $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
            $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $ReportDefinition[$Report]
            $EventsFound
        }

        $EventsRemoved = $Events.Count - $EventsFound.Count
        $Elapsed = Stop-TimeLog -Time $ExecutionTime -Option OneLiner
        if (-not $Quiet) { $Logger.AddInfoRecord("Events returned: $($EventsFound.Count), events skipped: $EventsRemoved") }
        if (-not $Quiet) { $Logger.AddInfoRecord("Ending beautification process, applying filters for $ReportNameTitle report - Time elapsed: $Elapsed") }

    }
}
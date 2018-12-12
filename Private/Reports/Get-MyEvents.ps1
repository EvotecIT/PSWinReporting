function Get-MyEvents {
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $ReportDefinition
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

        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('Report', $ReportRuntimeParam)
        return $RuntimeParamDic
    }
    Process {
        [string] $ReportName = $PSBoundParameters.Report

        $Logger.AddInfoRecord("Running $ReportName Report")
        $ExecutionTime = Start-TimeLog

        foreach ($Report in $ReportDefinition.Keys | Where-Object { $_ -ne 'Enabled' }) {
            $EventsType = $ReportDefinition[$Report].LogName
            $EventsNeeded = $ReportDefinition[$Report].Events
            $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
            $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $ReportDefinition[$Report]
            $EventsFound
        }

        $Elapsed = Stop-TimeLog -Time $ExecutionTime -Option OneLiner
        $Logger.AddInfoRecord("Ending $ReportName Report - Time elapsed: $Elapsed")
    }
}
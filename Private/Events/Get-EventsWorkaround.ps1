function Get-EventsWorkaround {
    [CmdLetBinding()]
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $IgnoreWords
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
        $MyReportDefinitions = $Script:ReportDefinitions.$ReportName

        foreach ($Report in $MyReportDefinitions.Keys | Where-Object { $_ -ne 'Enabled' }) {

            $MyReportDefinitions.$Report.IgnoreWords = $IgnoreWords
            $EventsType = $MyReportDefinitions[$Report].LogName
            $EventsNeeded = $MyReportDefinitions[$Report].Events
            $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
            $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $MyReportDefinitions[$Report]
            $Logger.AddInfoRecord("Events Processed: $($EventsFound.Count), EventsType: $EventsType EventsID: $EventsNeeded")
            $EventsFound
        }
    }
}
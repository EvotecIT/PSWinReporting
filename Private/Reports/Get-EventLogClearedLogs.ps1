function Get-EventLogClearedLogs {
    param(
        $Events,
        $Type,
        $IgnoreWords = ''
    )

    if ($Type -eq 'Security') {
        $Value = 'LogsClearedSecurity'
    } else {
        $Value = 'LogsClearedOther'
    }

    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.$Value.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.$Value.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.ReportsAD.EventBased.$Value
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.Value.SortBy
}
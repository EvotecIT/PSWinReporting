function Get-GroupCreateDelete {
    param(
        $Events,
        $IgnoreWords = ''
    )
    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.SortBy
}
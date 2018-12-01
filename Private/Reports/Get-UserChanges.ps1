function Get-UserChanges {
    param(
        [Array] $Events,
        $IgnoreWords = ''
    )
    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.UserChanges.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.UserChanges.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound `
        -EventsDefinition $Script:ReportDefinitions.ReportsAD.EventBased.UserChanges
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.UserChanges.SortBy
}
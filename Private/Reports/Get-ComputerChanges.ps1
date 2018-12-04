function Get-ComputerChanges {
    param(
        [Array] $Events,
        $IgnoreWords = ''
    )
    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.SortBy
}
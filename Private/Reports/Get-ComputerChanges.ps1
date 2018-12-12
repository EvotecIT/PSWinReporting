function Get-ComputerChanges {
    param(
        [Array] $Events,
        $IgnoreWords
    )
    $Script:ReportDefinitions.ComputerCreatedChanged.Events.IgnoreWords = $IgnoreWords

    $EventsType = $Script:ReportDefinitions.ComputerCreatedChanged.Events.LogName
    $EventsNeeded = $Script:ReportDefinitions.ComputerCreatedChanged.Events.Events

    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    return Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.ComputerCreatedChanged.Events
}
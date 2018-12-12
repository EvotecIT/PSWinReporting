function Get-UserChanges {
    param(
        [Array] $Events,
        $IgnoreWords
    )
    $Script:ReportDefinitions.UserChanges.Events.IgnoreWords = $IgnoreWords

    $EventsType = $Script:ReportDefinitions.UserChanges.Events.LogName
    $EventsNeeded = $Script:ReportDefinitions.UserChanges.Events.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    return Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.UserChanges.Events
}
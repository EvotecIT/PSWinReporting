function Get-UserLockouts {
    param(
        [Array] $Events,
        $IgnoreWords = ''
    )
    $Script:ReportDefinitions.UserLockouts.Events.IgnoreWords = $IgnoreWords

    $EventsType = $Script:ReportDefinitions.UserLockouts.Events.LogName
    $EventsNeeded = $Script:ReportDefinitions.UserLockouts.Events.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    return  Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.UserLockouts.Events
}
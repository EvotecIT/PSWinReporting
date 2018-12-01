function Get-UserStatuses {
    param (
        [Array] $Events,
        $IgnoreWords = ''
    )

    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.UserStatus.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.UserStatus.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.ReportsAD.EventBased.UserStatus
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.UserStatus.SortBy
}
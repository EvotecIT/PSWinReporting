function Get-UserStatuses {
    param (
        $Events,
        $IgnoreWords = ''
    )

    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.UserStatus.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.UserStatus.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -Fields $Script:ReportDefinitions.ReportsAD.EventBased.UserStatus.Fields
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.UserStatus.SortBy
}
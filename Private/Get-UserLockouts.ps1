function Get-UserLockouts {
    param(
        $Events,
        $IgnoreWords = ''
    )
    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.UserLockouts.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.UserLockouts.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -Fields $Script:ReportDefinitions.ReportsAD.EventBased.UserLockouts.Fields
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.UserLockouts.SortBy
}
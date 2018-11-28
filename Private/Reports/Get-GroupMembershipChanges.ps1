function Get-GroupMembershipChanges {
    param(
        $Events,
        $IgnoreWords = ''
    )
    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -Fields $Script:ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Fields
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.SortBy
}
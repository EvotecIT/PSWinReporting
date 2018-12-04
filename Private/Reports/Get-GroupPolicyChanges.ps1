function Get-GroupPolicyChanges {
    param(
        [Array] $Events,
        $IgnoreWords = ''
    )
    # 5136 Group Policy changes, value changes, links, unlinks.
    # 5137 Group Policy creations.
    # 5141 Group Policy deletions.

    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.SortBy
}
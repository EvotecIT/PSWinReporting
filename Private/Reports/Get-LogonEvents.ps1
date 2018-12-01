function Get-LogonEvents {
    param(
        [Array] $Events,
        $IgnoreWords = ''
    )
    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.UserLogon.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.UserLogon.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.ReportsAD.EventBased.UserLogon
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.UserLogon.SortBy

    <#
    # 4624: An account was successfully logged on
    # 4634: An account was logged off
    # 4647: User initiated logoff
    # 4672: Special privileges assigned to new logon                     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4672
    $EventsType = 'Security'
    $EventsNeeded = 4624
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
    #>
}
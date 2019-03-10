function Get-LogonEvents($Events, $IgnoreWords = '') {

    # 4624: An account was successfully logged on
    # 4634: An account was logged off
    # 4647: User initiated logoff
    # 4672: Special privileges assigned to new logon                     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4672
    $EventsType = 'Security'
    $EventsNeeded = 4624
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}
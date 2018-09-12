function Get-GroupMembershipChanges($Events, $IgnoreWords = '') {

    $EventsType = 'Security'
    $EventsNeeded = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { (($_.Message -split '\n')[0]).Trim() }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
    # 'Domain Controller', 'Action', 'Group Name','Member Name', 'Who', 'When', 'Event ID', 'Record ID'
}
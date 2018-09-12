function Get-GroupCreateDelete($Events, $IgnoreWords = '') {
    $EventsType = 'Security'
    $EventsNeeded = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { (($_.Message -split '\n')[0]).Trim() }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
    # 'Domain Controller', 'Action', 'Group Name', Who', 'When', 'Event ID', 'Record ID'
}
function Get-UserLockouts($Events, $IgnoreWords = '') {
    $EventsType = 'Security'
    $EventsNeeded = 4740
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { (($_.Message -split '\n')[0]).Trim() }},
    @{label = 'Computer Lockout On'; expression = { "$($_.TargetDomainName)" }},
    @{label = 'User Affected'; expression = { "$($_.TargetUserName)" }},
    @{label = 'Reported By'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { ($_.Date) }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }},
    @{label = 'Gathered From'; expression = { $_.GatheredFrom }},
    @{label = 'Gathered LogName'; expression = { $_.GatheredLogName }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
    # 'Domain Controller', 'Action','Computer Lockout On', 'User Affected','Reported By', 'When', 'Event ID', 'Record ID'
}
function Get-GroupPolicyChanges ($Events, $IgnoreWords = '') {
    # 5136 Group Policy changes, value changes, links, unlinks.
    # 5137 Group Policy creations.
    # 5141 Group Policy deletions.
    $EventsType = 'Security'
    $EventsNeeded = 5136, 5137, 5141
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { (($_.Message -split '\n')[0]).Trim() }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }},
    @{label = 'OperationType'; expression = { Convert-FromGPO -OperationType $_.OperationType }},
    DSName, DSType, ObjectDN, ObjectGUID, ObjectClass, AttributeLDAPDisplayName, AttributeSyntaxOID,
    AttributeValue, Id, Task | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
    # 'Domain Controller', 'Action', 'who, 'When', 'Event ID', 'Record ID', 'OperationType'
}
function Get-EventLogClearedLogs($Events, $Type, $IgnoreWords = '') {
    if ($Type -eq 'Security') {
        $EventsNeeded = 1102, 1105
        $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType 'Security'
    } else {
        $EventsNeeded = 104
        $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType 'System'
    }
    #return $EventsFound
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { (($_.Message -split '\n')[0]).Trim() }},
    @{label = 'Backup Path'; expression = { if ($_.BackupPath -eq $null) { 'N/A' } else { $_.BackupPath} }},
    @{label = 'Log Type'; expression = { if ($Type -eq 'Security') { 'Security' } else {  $_.Channel } }},
    @{label = 'Who'; expression = { if ($_.ID -eq 1105) { "Automatic Backup" } else { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }}},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
    # 'Domain Controller', 'Action', 'Backup Path, 'Log Type','Who', 'When', 'Event ID', 'Record ID'
}
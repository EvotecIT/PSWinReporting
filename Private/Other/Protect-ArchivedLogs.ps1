function Protect-ArchivedLogs {
    [CmdletBinding()]
    param (
        $TableEventLogClearedLogs,
        [string] $DestinationPath
    )

    <#
        $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
        @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
        @{label = 'Backup Path'; expression = { if ($_.BackupPath -eq $null) { 'N/A' } else { $_.BackupPath} }},
        @{label = 'Log Type'; expression = { if ($Type -eq 'Security') { 'Security' } else {  $_.Channel } }},
        @{label = 'Who'; expression = { if ($_.ID -eq 1105) { "Automatic Backup" } else { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }}},
        @{label = 'When'; expression = { $_.Date }},
        @{label = 'Event ID'; expression = { $_.ID }},
        @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
        $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    #>
    foreach ($BackupEvent in $TableEventLogClearedLogs) {
        if ($BackupEvent.'Event ID' -eq 1105) {
            $SourcePath = $BackupEvent.'Backup Path'
            $ServerName = $BackupEvent.'Domain Controller'
            if ($SourcePath -and $ServerName -and $DestinationPath) {
                Write-Color @script:WriteParameters '[i] Found Event Log file ', $SourcePath, ' on ', $ServerName, '. Will try moving to: ', $DestinationPath -Color White, Yellow, White, Yellow
                Move-ArchivedLogs -ServerName $ServerName -SourcePath $SourcePath -DestinationPath $DestinationPath
            }
        }
    }
}

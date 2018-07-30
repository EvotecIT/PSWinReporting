function Get-GroupCreateDelete($Events, $IgnoreWords = '') {
    $EventsType = 'Security'
    $EventsNeeded = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}
function Get-GroupMembershipChanges($Events, $IgnoreWords = '') {

    $EventsType = 'Security'
    $EventsNeeded = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}
function Get-UserStatuses {
    param (
        $Events,
        $IgnoreWords = ''
    )

    $EventsType = 'Security'
    $EventsNeeded = 4722, 4725, 4767, 4723, 4724, 4726
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'User Affected'; expression = { "$($_.TargetDomainName)\$($_.TargetUserName)" }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}
function Get-UserLockouts($Events, $IgnoreWords = '') {
    $EventsType = 'Security'
    $EventsNeeded = 4740
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Computer Lockout On'; expression = { "$($_.TargetDomainName)" }},
    @{label = 'User Affected'; expression = { "$($_.TargetUserName)" }},
    @{label = 'Reported By'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { ($_.Date) }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}
function Get-UserChanges($Events, $IgnoreWords = '') {

    $EventsFoundCleaned = @()
    $EventsType = 'Security'
    $EventsNeeded = 4720, 4738
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType

    # Cleanup Anonymous LOGON (usually related to password events)
    # https://social.technet.microsoft.com/Forums/en-US/5b2a93f7-7101-43c1-ab53-3a51b2e05693/eventid-4738-user-account-was-changed-by-anonymous?forum=winserverDS
    foreach ($u in $EventsFound) {
        if ($u.SubjectUserName -eq "ANONYMOUS LOGON") { }
        else { $EventsFoundCleaned += $u }
    }
    $EventsFoundCleaned = $EventsFoundCleaned | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'User Affected'; expression = { "$($_.TargetDomainName)\$($_.TargetUserName)" }},
    @{label = 'SamAccountName'; expression = { $_.SamAccountName }},
    @{label = 'Display Name'; expression = { $_.DisplayName }},
    @{label = 'UserPrincipalName'; expression = { $_.UserPrincipalName }},
    @{label = 'Home Directory'; expression = { $_.HomeDirectory }},
    @{label = 'Home Path'; expression = { $_.HomePath }},
    @{label = 'Script Path'; expression = { $_.ScriptPath }},
    @{label = 'Profile Path'; expression = { $_.ProfilePath }},
    @{label = 'User Workstations'; expression = { $_.UserWorkstations }},
    @{label = 'Password Last Set'; expression = { $_.PasswordLastSet }},
    @{label = 'Account Expires'; expression = { $_.AccountExpires }},
    @{label = 'Primary Group Id'; expression = { $_.PrimaryGroupId }},
    @{label = 'Allowed To Delegate To'; expression = { $_.AllowedToDelegateTo }},
    @{label = 'Old Uac Value'; expression = { Convert-UAC $_.OldUacValue }},
    @{label = 'New Uac Value'; expression = { Convert-UAC $_.NewUacValue }},
    @{label = 'User Account Control'; expression = {
            foreach ($u in $_.UserAccountControl) {
                Convert-UAC ($u -replace "%%", "")
            }
        }
    },
    @{label = 'User Parameters'; expression = { $_.UserParameters }},
    @{label = 'Sid History'; expression = { $_.SidHistory }},
    @{label = 'Logon Hours'; expression = { $_.LogonHours }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}  | Sort-Object When

    $EventsFoundCleaned = Find-EventsIgnored -Events $EventsFoundCleaned -IgnoreWords $IgnoreWords
    return $EventsFoundCleaned
}
function Get-GroupPolicyChanges ($Events, $IgnoreWords = '') {
    # 5136 Group Policy changes, value changes, links, unlinks.
    # 5137 Group Policy creations.
    # 5141 Group Policy deletions.
    $EventsType = 'Security'
    $EventsNeeded = 5136, 5137, 5141
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }},
    @{label = 'OperationType'; expression = { Convert-FromGPO -OperationType $_.OperationType }},
    DSName, DSType, ObjectDN, ObjectGUID, ObjectClass, AttributeLDAPDisplayName, AttributeSyntaxOID,
    AttributeValue, Id, Task | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}
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

function Get-LogonEventsKerberos($Events, $IgnoreWords = '') {
    $EventsType = 'Security'
    $EventsNeeded = 4768
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Computer/User Affected'; expression = { "$($_.TargetDomainName)\$($_.TargetUserName)" }},
    @{label = 'IpAddress'; expression = { if ($_.IpAddress -match "::1" ) { "localhost" }   else {     $_.IpAddress       }     }},
    @{label = 'Port'; expression = { $_.IpPort }},


    @{label = 'TicketOptions'; expression = { $_.TicketOptions }},
    @{label = 'Status'; expression = { $_.Status }},
    @{label = 'TicketEncryptionType'; expression = { $_.TicketEncryptionType }},
    @{label = 'PreAuthType'; expression = { $_.PreAuthType }},

    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}
function Get-RebootEvents($Events, $IgnoreWords = '') {
    # -LogName "System" -Provider "User32"
    # -LogName "System" -Provider "Microsoft-Windows-WER-SystemErrorReporting" -EventID 1001, 1018
    # -LogName "System" -Provider "Microsoft-Windows-Kernel-General" -EventID 1, 12, 13
    # -LogName "System" -Provider "Microsoft-Windows-Kernel-Power" -EventID 42, 41, 109
    # -LogName "System" -Provider "Microsoft-Windows-Power-Troubleshooter" -EventID 1
    # -LogName "System" -Provider "Eventlog" -EventID 6005, 6006, 6008, 6013

    $EventsNeeded = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013 | Sort-Object -Unique
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType 'System'
    $EventsFound = $EventsFound | Select-Object ID, Computer, TimeCreated, Message
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}

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
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Backup Path'; expression = { if ($_.BackupPath -eq $null) { 'N/A' } else { $_.BackupPath} }},
    @{label = 'Log Type'; expression = { if ($Type -eq 'Security') { 'Security' } else {  $_.Channel } }},
    @{label = 'Who'; expression = { if ($_.ID -eq 1105) { "Automatic Backup" } else { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }}},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}
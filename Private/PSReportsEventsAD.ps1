function Get-GroupCreateDelete($Events) {
    Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    $EventsType = 'Security'
    $EventsNeeded = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }} | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    return $EventsFound
}
function Get-GroupMembershipChanges($Events) {
    Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report" -Color White, Green, White, Green, White, Green, White
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
    Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report." -Color White, Green, White, Green, White, Green, White
    return $EventsFound
}
function Get-UserStatuses($Events) {
    Write-Color @script:WriteParameters "[i] Running ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
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
    Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
    return $EventsFound
}
function Get-UserLockouts($Events) {
    Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
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
    Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
    return $EventsFound
}
function Get-UserChanges($Events) {
    Write-Color @script:WriteParameters "[i] Running ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
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
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $EventsFoundCleaned = $EventsFoundCleaned | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
    return $EventsFoundCleaned
}
function Get-GroupPolicyChanges ($Events) {
    Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
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

    Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
    return $EventsFound
}
function Get-LogonEvents($Events) {
    Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    # 4624: An account was successfully logged on
    # 4634: An account was logged off
    # 4647: User initiated logoff
    # 4672: Special privileges assigned to new logon                     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4672
    $EventsType = 'Security'
    $EventsNeeded = 4624
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    return $EventsFound
}
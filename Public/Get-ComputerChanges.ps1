function Get-ComputerChanges {
    param(
        $Events,
        $IgnoreWords = ''
    )
    $EventsFoundCleaned = @()
    $EventsType = 'Security'
    $EventsNeeded = 4741, 4742
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType

    # Cleanup Anonymous LOGON (usually related to password events)
    # https://social.technet.microsoft.com/Forums/en-US/5b2a93f7-7101-43c1-ab53-3a51b2e05693/eventid-4738-user-account-was-changed-by-anonymous?forum=winserverDS
    foreach ($u in $EventsFound) {
        if ($u.SubjectUserName -eq "ANONYMOUS LOGON") { }
        else { $EventsFoundCleaned += $u }
    }
    $EventsFoundCleaned = $EventsFoundCleaned | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { (($_.Message -split '\n')[0]).Trim() }},
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
    @{label = 'Record ID'; expression = { $_.RecordId }},
    @{label = 'Gathered From'; expression = { $_.GatheredFrom }},
    @{label = 'Gathered LogName'; expression = { $_.GatheredLogName }} | Sort-Object When

    $EventsFoundCleaned = Find-EventsIgnored -Events $EventsFoundCleaned -IgnoreWords $IgnoreWords
    return $EventsFoundCleaned
    # 'Domain Controller', 'Action','User Affected', 'User Affected','SamAccountName', 'Display Name','UserPrincipalName',
    # 'Home Directory', 'Home Path', 'Script Path', 'Profile Path','User Workstation', 'Password Last Set','Account Expires'
    # 'Primary Group Id','Allowed To Delegate To','Old Uac Value','User Account Control','User Parameters', 'Sid History'
    # 'Logon Hours', 'Who, 'When', 'Event ID', 'Record ID'
}
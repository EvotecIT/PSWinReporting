function Get-GroupCreateDelete($Servers, $Dates) {

    # 4727: A security-enabled global group was created                   https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4727
    # 4730: A security-enabled global group was deleted                   https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4730

    # 4731: A security-enabled local group was created                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4731
    # 4734: A security-enabled local group was deleted                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4734

    # 4759: A security-disabled universal group was created               https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4759
    # 4760: A security-disabled universal group was changed               https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4760

    # 4754: A security-enabled universal group was created.              https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4754
    # 4758: A security-enabled universal group was deleted                https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4756
    Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $GroupMembershipChangesEventID = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
        $GroupMembershipChanges = Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $GroupMembershipChangesEventID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeGroupCreateDelete.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $GroupMembershipChangesOutput = $GroupMembershipChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $GroupMembershipChangesOutput = $GroupMembershipChangesOutput | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $GroupMembershipChangesOutput
}
function Get-GroupMembershipChanges($Servers, $Dates) {

    # Events processed
    # 4728: A member was added to a security-enabled global group -       https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4728
    # 4729: A member was removed from a security-enabled global group     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4729
    # 4732: A member was added to a security-enabled local group -  -     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4732
    # 4733: A member was removed from a security-enabled local group -    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4733
    # 4756: A member was added to a security-enabled universal group      https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4756
    # 4757: A member was removed from a security-enabled universal group  https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4757
    # 4761: A member was added to a security-disabled universal group     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4761
    # 4762: A member was removed from a security-disabled universal group https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4762

    Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $GroupMembershipChangesEventID = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
    $GroupMembershipChanges = @()
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
        $GroupMembershipChanges += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $GroupMembershipChangesEventID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeGroupEvents.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $GroupMembershipChangesOutput = $GroupMembershipChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $GroupMembershipChangesOutput = $GroupMembershipChangesOutput | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $GroupMembershipChangesOutput
}
function Get-UserStatuses($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "User Statues Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $UserChangesID = 4722, 4725, 4767, 4723, 4724, 4726
    $UserChanges = @()
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $UserChanges += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $UserChangesID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeUserStatuses.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $UserChangesOutput = $UserChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'User Affected'; expression = { "$($_.TargetDomainName)\$($_.TargetUserName)" }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $UserChangesOutput = $UserChangesOutput | Sort-Object Whacen
    Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $UserChangesOutput
}
function Get-UserLockouts($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $UserChangesID = 4740
    $UserChanges = @()
    foreach ($server in $servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $UserChanges += Get-Events -Computer $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $UserChangesID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeUserLockouts.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $UserChangesOutput = $UserChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Computer Lockout On'; expression = { "$($_.TargetDomainName)" }},
    @{label = 'User Affected'; expression = { "$($_.TargetUserName)" }},
    @{label = 'Reported By'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { ($_.Date) }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $UserChangesOutput = $UserChangesOutput | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $UserChangesOutput

}
function Get-UserChanges($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "User Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $userChangesCleanedUp = @()
    $UserChangesID = 4720, 4738
    $UserChanges = @()
    foreach ($server in $servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
        $UserChanges += Get-Events -Computer $Server -DateFrom $($Dates.DateFrom) -DateTo $($Dates.DateTo) -EventID $UserChangesID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeUserEvents.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    # Cleanup Anonymous LOGON (usually related to password events)
    # https://social.technet.microsoft.com/Forums/en-US/5b2a93f7-7101-43c1-ab53-3a51b2e05693/eventid-4738-user-account-was-changed-by-anonymous?forum=winserverDS
    #$userChanges

    foreach ($u in $UserChanges) {
        if ($u.SubjectUserName -eq "ANONYMOUS LOGON") { }
        else { $userChangesCleanedUp += $u }
    }
    $UserChangesOutput = $userChangesCleanedUp | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
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
    $UserChangesOutput = $UserChangesOutput | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $UserChangesOutput
}
function Get-GroupPolicyChanges ($Servers, $Dates) {
    $EventID = 5136, 5137, 5141
    # 5136 Group Policy changes, value changes, links, unlinks.
    # 5137 Group Policy creations.
    # 5141 Group Policy deletions.
    $GroupMembershipChanges = @()

    Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $GroupMembershipChanges += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $EventID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeGroupPolicyChanges.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $GroupMembershipChangesOutput = $GroupMembershipChanges
    <#
      $GroupMembershipChangesOutput = $GroupMembershipChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
      @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
      @{label = 'Group Name'; expression = { $_.TargetUserName }},
      @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
      @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
      @{label = 'When'; expression = { $_.Date }},
      @{label = 'Event ID'; expression = { $_.ID }},
      @{label = 'Record ID'; expression = { $_.RecordId }}

      #$GroupMembershipChangesOutput = $GroupMembershipChangesOutput | Sort-Object When
    #>
    Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $GroupMembershipChangesOutput
}
function Get-LogonEvents($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White

    # 4624: An account was successfully logged on
    # 4634: An account was logged off
    # 4647: User initiated logoff
    # 4672: Special privileges assigned to new logon                     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4672


    $EventIDs = 4624 #, 4364, 4647, 4672
    $Events = @()
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $Events += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $EventIDs -ReportOptions $ReportOptions -LogType "Security"

        $script:TimeToGenerateReports.Reports.IncludeLogonEvents.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $Events
}
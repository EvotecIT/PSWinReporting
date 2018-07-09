function Start-TeamsReport {
    param(
        $EventID,
        $EventRecordID,
        $EventChannel,
        [string] $TeamsID
    )
    # Declare variables
    $EventLogTable = @()
    $GroupsEventsTable = @()
    $UsersEventsTable = @()
    $UsersEventsStatusesTable = @()
    $UsersLockoutsTable = @()
    $LogonEvents = @()
    $LogonEventsKerberos = @()
    $RebootEventsTable = @()
    $TableGroupPolicyChanges = @()
    $TableEventLogClearedLogs = @()
    $GroupCreateDeleteTable = @()

    $Events = Get-Events -Server 'EVO1' -LogName 'ForwardedEvents' -EventID $eventid | Where {$_.RecordID -eq $eventRecordID }

    ### USER EVENTS STARTS ###
    # if ($ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -eq $true) {
    Write-Color @script:WriteParameters "[i] Running ", "User Changes Report." -Color White, Green, White, Green, White, Green, White

    $UsersEventsTable = Get-UserChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserChanges.IgnoreWords
    # $script:TimeToGenerateReports.Reports.UserChanges.Total = Stop-TimeLog -Time $ExecutionTime
    Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
    # }
    #if ($ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -eq $true) {
    Write-Color @script:WriteParameters "[i] Running ", "User Statues Report." -Color White, Green, White, Green, White, Green, White

    $UsersEventsStatusesTable = Get-UserStatuses -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserStatus.IgnoreWords
    #   $script:TimeToGenerateReports.Reports.UserStatus.Total = Stop-TimeLog -Time $ExecutionTime
    Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
    #}
    #If ($ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -eq $true) {
    Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
    # $ExecutionTime = Start-TimeLog # Timer
    $UsersLockoutsTable = Get-UserLockouts -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLockouts.IgnoreWords
    #   $script:TimeToGenerateReports.Reports.UserLockouts.Total = Stop-TimeLog -Time $ExecutionTime
    Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
    #}
    #if ($ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -eq $true) {
    Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    #   $ExecutionTime = Start-TimeLog # Timer
    $LogonEvents = Get-LogonEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogon.IgnoreWords
    Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    Write-Color @script:WriteParameters "[i] Running ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
    $LogonEventsKerberos = Get-LogonEventsKerberos -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.IgnoreWords
    Write-Color @script:WriteParameters "[i] Ending ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
    Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report" -Color White, Green, White, Green, White, Green, White
    $GroupsEventsTable = Get-GroupMembershipChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.IgnoreWords
    Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report." -Color White, Green, White, Green, White, Green, White
    Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    $GroupCreateDeleteTable = Get-GroupCreateDelete -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.IgnoreWords
    Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    Write-Color @script:WriteParameters "[i] Running ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
    $RebootEventsTable = Get-RebootEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.EventsReboots.IgnoreWords
    Write-Color @script:WriteParameters "[i] Ending ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
    Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
    $TableGroupPolicyChanges = Get-GroupPolicyChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.IgnoreWords
    Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
    Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
    $TableEventLogClearedLogs = Get-EventLogClearedLogs -Events $Events -Type 'Security' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.IgnoreWords
    Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
    Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
    $TableEventLogClearedLogsOther = Get-EventLogClearedLogs -Events $Events -Type 'Other' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.IgnoreWords
    Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White

    Send-ToTeams $GroupsEventsTable -TeamsID $TeamsID
    Send-ToTeams $UsersEventsTable -TeamsID $TeamsID
    Send-ToTeams $UsersLockoutsTable -TeamsID $TeamsID
    Send-ToTeams $UsersEventsStatusesTable -TeamsID $TeamsID
    Send-ToTeams $TableGroupPolicyChanges -TeamsID $TeamsID
    Send-ToTeams $TableEventLogClearedLogs -TeamsID $TeamsID
    Send-ToTeams $GroupCreateDeleteTable -TeamsID $TeamsID
}

function Send-ToTeams {
    param(
        [System.Object] $Events,
        [string] $TeamsID
    )
    Import-Module PSTeams -Force
    if ($Events -ne $null) {
        foreach ($Event in $Events) {
            $MessageTitle = 'Active Directory Changes'
            $MessageBody = 'Body'
            $ActivityTitle = $Event.Action
            # $ActivitySubtitle = 'Subtitle'
            $Details = @()
            foreach ($Property in $event.PSObject.Properties) {
                if ($Property.Name -eq 'When') {
                    $Details += @{ name = $Property.Name; value = $Property.Value.DateTime }
                } else {
                    $Details += @{ name = $Property.Name; value = $Property.Value }
                }
            }
            $Action = $Event.Action
            if ($Action -like '*added*') {
                [MessageType] $MessageType = [MessageType]::Add
            } elseif ($Action -like '*remove*') {
                [MessageType] $MessageType = [MessageType]::Minus
            } else {
                [MessageType] $MessageType = [MessageType]::Alert
            }
            $data = Send-TeamChannelMessage -messageSummary $MessageBody -MessageType $MessageType -MessageTitle $MessageTitle -URI $TeamsID -ActivityTitle $ActivityTitle -Details $Details -Supress $false
        }
    }
}

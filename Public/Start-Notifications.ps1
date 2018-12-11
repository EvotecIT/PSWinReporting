function Start-Notifications {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary]$ReportOptions,
        [System.Collections.IDictionary] $ReportDefinitions,
        [int] $EventID,
        [int64] $EventRecordID,
        [string] $EventChannel,
        [System.Collections.IDictionary] $LoggerParameters
    )
    <#
        Set logger
    #>
    if (-not $LoggerParameters) {
        $LoggerParameters = @{
            ShowTime   = $true
            LogsDir    = 'C:\temp\logs'
            TimeFormat = 'yyyy-MM-dd HH:mm:ss'
        }
    }

    $Params = @{
        LogPath = Join-Path $LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log"
        ShowTime = $LoggerParameters.ShowTime
        TimeFormat = $LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params

    Write-Color @script:WriteParameters -Text '[i] Executed ', 'Trigger', ' for ID: ', $eventid, ' and RecordID: ', $eventRecordID -Color White, Yellow, White, Yellow, White, Yellow

    Write-Color @script:WriteParameters -Text '[i] Using Microsoft Teams: ', $ReportOptions.Notifications.MicrosoftTeams.Use -Color White, Yellow
    if ($ReportOptions.Notifications.MicrosoftTeams.Use) {
        if ($($ReportOptions.Notifications.MicrosoftTeams.TeamsID).Count -gt 50) {
            Write-Color @script:WriteParameters -Text '[i] TeamsID: ', "$($($ReportOptions.Notifications.MicrosoftTeams.TeamsID).Substring(0, 50))..." -Color White, Yellow
        } else {
            Write-Color @script:WriteParameters -Text '[i] TeamsID: ', "$($($ReportOptions.Notifications.MicrosoftTeams.TeamsID))..." -Color White, Yellow
        }
    }
    Write-Color @script:WriteParameters -Text '[i] Using Slack: ', $ReportOptions.Notifications.Slack.Use -Color White, Yellow
    if ($ReportOptions.Notifications.Slack.Use) {
        if ($($ReportOptions.Notifications.Slack.URI).Count -gt 25) {
            Write-Color @script:WriteParameters -Text '[i] Slack URI: ', "$($($ReportOptions.Notifications.Slack.URI).Substring(0, 25))..." -Color White, Yellow
        } else {
            Write-Color @script:WriteParameters -Text '[i] Slack URI: ', "$($($ReportOptions.Notifications.Slack.URI))..." -Color White, Yellow
        }
        Write-Color @script:WriteParameters -Text '[i] Slack Channel: ', "$($($ReportOptions.Notifications.Slack.Channel))" -Color White, Yellow
    }

    Write-Color @script:WriteParameters -Text '[i] Using MSSQL: ', $ReportOptions.Notifications.MSSQL.Use -Color White, Yellow


    if (-not $ReportOptions.Notifications.Slack.Use -and -not $ReportOptions.Notifications.MicrosoftTeams.Use -and -not $ReportOptions.Notifications.MSSQL.Use) {
        # Terminating as no options are $true
        return
    }

    $GroupsEventsTable = @()
    $GroupCreateDeleteTable = @()
    $UsersEventsTable = @()
    $UsersEventsStatusesTable = @()
    $UsersLockoutsTable = @()
    $LogonEvents = @()
    $LogonEventsKerberos = @()
    $RebootEventsTable = @()
    $TableGroupPolicyChanges = @()
    $TableEventLogClearedLogs = @()
    $TableEventLogClearedLogsOther = @()
    $ComputerChanges = @()
    $ComputerDeleted = @()
    #$Events = Get-Events -Server $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -EventID $eventid -Verbose:$ReportOptions.Debug.Verbose | Where { $_.RecordID -eq $EventRecordID }
    $Events = Get-Events -Server $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -EventID $eventid -RecordID $eventRecordID -Verbose:$ReportOptions.Debug.Verbose
    ### USER EVENTS STARTS ###
    if ($ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Changes Report." -Color White, Green, White, Green, White, Green, White

        $UsersEventsTable = Get-UserChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserChanges.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Statues Report." -Color White, Green, White, Green, White, Green, White

        $UsersEventsStatusesTable = Get-UserStatuses -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserStatus.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White

        $UsersLockoutsTable = Get-UserLockouts -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLockouts.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White

        $LogonEvents = Get-LogonEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogon.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White

        $LogonEventsKerberos = Get-LogonEventsKerberos -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
    }
    ### USER EVENTS END ###

    if ($ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Computer Created / Changed Report." -Color White, Green, White, Green, White, Green, White

        $ComputerChanges = Get-ComputerChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "Computer Created / Changed Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Computer Deleted Report." -Color White, Green, White, Green, White, Green, White

        $ComputerDeleted = Get-ComputerStatus -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "Computer Deleted Report." -Color White, Green, White, Green, White, Green, White
    }


    if ($ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report" -Color White, Green, White, Green, White, Green, White

        $GroupsEventsTable = Get-GroupMembershipChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White

        $GroupCreateDeleteTable = Get-GroupCreateDelete -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White

        $RebootEventsTable = Get-RebootEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.EventsReboots.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White

        $TableGroupPolicyChanges = Get-GroupPolicyChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.IgnoreWords

        Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -eq $true) {

        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogs = Get-EventLogClearedLogs -Events $Events -Type 'Security' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.IgnoreWords
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White

    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -eq $true) {

        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogsOther = Get-EventLogClearedLogs -Events $Events -Type 'Other' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.IgnoreWords
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White

    }

    Send-Notificaton -Events $UsersEventsTable -ReportOptions $ReportOptions
    Send-Notificaton -Events $UsersLockoutsTable -ReportOptions $ReportOptions
    Send-Notificaton -Events $UsersEventsStatusesTable -ReportOptions $ReportOptions
    Send-Notificaton -Events $TableGroupPolicyChanges -ReportOptions $ReportOptions
    Send-Notificaton -Events $TableEventLogClearedLogs -ReportOptions $ReportOptions
    Send-Notificaton -Events $TableEventLogClearedLogsOther -ReportOptions $ReportOptions
    Send-Notificaton -Events $GroupsEventsTable -ReportOptions $ReportOptions
    Send-Notificaton -Events $GroupCreateDeleteTable -ReportOptions $ReportOptions
    Send-Notificaton -Events $LogonEvents -ReportOptions $ReportOptions
    Send-Notificaton -Events $LogonEventsKerberos -ReportOptions $ReportOptions
    Send-Notificaton -Events $RebootEventsTable -ReportOptions $ReportOptions
    Send-Notificaton -Events $ComputerChanges -ReportOptions $ReportOptions
    Send-Notificaton -Events $ComputerDeleted -ReportOptions $ReportOptions

    if ($ReportOptions.Backup.Use) {
        Protect-ArchivedLogs -TableEventLogClearedLogs $TableEventLogClearedLogs -DestinationPath $ReportOptions.Backup.DestinationPath -Verbose:$ReportOptions.Debug.Verbose
    }
}
function Move-ArchivedLogs {
    [CmdletBinding()]
    param (
        $ServerName,
        $SourcePath,
        $DestinationPath
    )
    $NewSourcePath = "\\$ServerName\$($SourcePath.Replace(':\','$\'))"
    $PathExists = Test-Path $NewSourcePath
    if ($PathExists) {
        Write-Color @script:WriteParameters '[i] Moving log file from ', $NewSourcePath, ' to ', $DestinationPath -Color White, Yellow, White, Yellow
        Move-Item -Path $NewSourcePath -Destination $DestinationPath -WhatIf
        if (!$?) {
            Write-Color @script:WriteParameters '[i] File ', $NewSourcePath, ' couldn not be moved.' -Color White, Yellow, White
        }
    }
}

function Protect-ArchivedLogs {
    [CmdletBinding()]
    param (
        $TableEventLogClearedLogs,
        $DestinationPath
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
                Write-Color @script:WriteParameters '[i] Found log file ', $SourcePath, ' on ', $ServerName, ' moving to ', $DestinationPath -Color White, Yellow, White, Yellow
                Move-ArchivedLogs -ServerName $ServerName -SourcePath $SourcePath -DestinationPath $DestinationPath
            }
        }
    }
}

function Start-Notifications {
    [CmdletBinding()]
    param(
        $ReportOptions,
        $ReportDefinitions,
        $EventID,
        $EventRecordID,
        $EventChannel
    )
    Set-DisplayParameters -ReportOptions $ReportOptions -DisplayProgress $false

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


    #Write-Color @script:WriteParameters -Text "Start-TeamsReport (PSWinReporting) - This is a PSSCRIPTROOT path ", " $PSScriptRoot"
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
    #$Events = Get-Events -Server $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -EventID $eventid -Verbose:$ReportOptions.Debug.Verbose | Where { $_.RecordID -eq $EventRecordID }
    $Events = Get-Events -Server $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -EventID $eventid -RecordID $eventRecordID -Verbose:$ReportOptions.Debug.Verbose
    ### USER EVENTS STARTS ###
    if ($ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsTable = Get-UserChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsStatusesTable = Get-UserStatuses -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserStatus.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserStatus.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersLockoutsTable = Get-UserLockouts -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLockouts.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLockouts.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $LogonEvents = Get-LogonEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogon.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLogon.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $LogonEventsKerberos = Get-LogonEventsKerberos -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLogonKerberos.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
    }
    ### USER EVENTS END ###

    if ($ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report" -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer St
        $GroupsEventsTable = Get-GroupMembershipChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupMembershipChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $GroupCreateDeleteTable = Get-GroupCreateDelete -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupCreateDelete.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $RebootEventsTable = Get-RebootEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.EventsReboots.IgnoreWords
        $script:TimeToGenerateReports.Reports.EventsReboots.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $TableGroupPolicyChanges = Get-GroupPolicyChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupPolicyChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogs = Get-EventLogClearedLogs -Events $Events -Type 'Security' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.IgnoreWords
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.LogsClearedSecurity.Total = Stop-TimeLog -Time $ExecutionTime
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogsOther = Get-EventLogClearedLogs -Events $Events -Type 'Other' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.IgnoreWords
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.LogsClearedOther.Total = Stop-TimeLog -Time $ExecutionTime
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

    if ($ReportOptions.Backup.Use) {
        Protect-ArchivedLogs -TableEventLogClearedLogs $TableEventLogClearedLogs -DestinationPath $ReportOptions.DestinationPath -Verbose:$ReportOptions.Debug.Verbose
    }
}

function Send-Notificaton {
    [CmdletBinding()]
    param(
        [System.Object] $Events,
        [hashtable] $ReportOptions
    )


    if ($Events -ne $null) {
        foreach ($Event in $Events) {

            $MessageTitle = 'Active Directory Changes'
            [string] $ActivityTitle = $($Event.Action).Trim()
            if ($ActivityTitle -like '*added*') {
                $Color = [System.Drawing.Color]::Green
                $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20120.png'
            } elseif ($ActivityTitle -like '*remove*') {
                $Color = [System.Drawing.Color]::Red
                $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20130.png'
            } else {
                $Color = [System.Drawing.Color]::Yellow
                $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20140.png'
            }

            $FactsSlack = @()
            $FactsTeams = @()
            foreach ($Property in $event.PSObject.Properties) {
                if ($Property.Value -ne $null -and $Property.Value -ne '') {
                    if ($Property.Name -eq 'When') {
                        $FactsTeams += New-TeamsFact -Name $Property.Name -Value $Property.Value.DateTime
                        $FactsSlack += @{ title = $Property.Name; value = $Property.Value.DateTime; short = $true }
                    } else {
                        $FactsTeams += New-TeamsFact -Name $Property.Name -Value $Property.Value
                        $FactsSlack += @{ title = $Property.Name; value = $Property.Value; short = $true }
                    }
                }
            }

            if ($ReportOptions.Notifications.Slack.Use) {

                $Data = New-SlackMessageAttachment -Color $Color `
                    -Title "$MessageTitle - $ActivityTitle"  `
                    -Fields $FactsSlack `
                    -Fallback 'Your client is bad' |
                    New-SlackMessage -Channel $ReportOptions.Notifications.Slack.Channel `
                    -IconEmoji :bomb: |
                    Send-SlackMessage -Uri $ReportOptions.Notifications.Slack.URI

                Write-Color @script:WriteParameters -Text "[i] Slack output: ", $Data -Color White, Yellow
            }
            if ($ReportOptions.Notifications.MicrosoftTeams.Use) {

                $Section1 = New-TeamsSection `
                    -ActivityTitle $ActivityTitle `
                    -ActivityImageLink $ActivityImageLink `
                    -ActivityDetails $FactsTeams

                $Data = Send-TeamsMessage `
                    -URI $ReportOptions.Notifications.MicrosoftTeams.TeamsID `
                    -MessageTitle $MessageTitle `
                    -Color $Color `
                    -Sections $Section1 `
                    -Supress $false #`
                # -Verbose
                Write-Color @script:WriteParameters -Text "[i] Teams output: ", $Data -Color White, Yellow
            }
            if ($ReportOptions.Notifications.MSSQL.Use) {
                Write-Color @script:WriteParameters -Text "Event was found but not sent anywhere yet", $Data -Color White, Yellow
                New-SqlInsert -Events $Events -ReportOptions $ReportOptions

            }
        }
    }
}

function New-SqlInsert {
    # [CmdletBinding()]
    param(
        [System.Object] $Events,
        [hashtable] $ReportOptions
    )

    $Query = New-Query -Events $Events -ReportOptions $ReportOptions
    $Data = Invoke-Sqlcmd2 -SqlInstance $ReportOptions.Notifications.MSSQL.Server -Database $ReportOptions.Notifications.MSSQL.Database -Query $Query
}

function New-Query {
    param (
        $ReportOptions,
        $Events
    )
    #$Events | fl *

    $TableMapping = $ReportOptions.Notifications.MSSQL.TableMapping
    $SQLTable = $ReportOptions.Notifications.MSSQL.Table

    $ArrayMain = New-ArrayList
    $ArrayKeys = New-ArrayList
    $ArrayValues = New-ArrayList
    Add-ToArray -List $ArrayMain -Element "INSERT INTO $SQLTable ("
    foreach ($E in $Events.PSObject.Properties) {
        $FieldName = $E.Name
        $FieldValue = $E.Value

        foreach ($MapKey in $TableMapping.Keys) {
            $MapValue = $TableMapping.$MapKey
            if ($FieldName -eq $MapValue) {

                #Write-Color $FieldName, ' ', $MapKey, ' ', $MapValue, ' ', $FieldValue -Color Red, White, Yellow, White, Red, White, Yellow
                #  $MapKey
                Add-ToArray -List $ArrayKeys -Element "[$MapKey]"
                #  $FieldValue
                Add-ToArray -List $ArrayValues -Element "'$FieldValue'"
            }
        }
    }

    Add-ToArray -List $ArrayMain -Element ($ArrayKeys -join ',')
    Add-ToArray -List $ArrayMain -Element ') VALUES ('
    Add-ToArray -List $ArrayMain -Element ($ArrayValues -join ',')
    Add-ToArray -List $ArrayMain -Element ')'

    #Write-Color $ArrayKeys -COlor White
    #Write-Color $ArrayMain -Color Red
    #Write-Color $ArrayValues -COlor White
    # $Map
    # $ReportOptions.Notifications.MSSQL.TableMapping.$Map
    #  }
    $ArrayMain | Out-File 'C:\test.txt'
    return $ArrayMain -join ' '

    $Mapping = @{
        # 'ID'                  = '<PrimaryKey>'
        'EventType'           = ''
        'EventID'             = 'Event ID'
        'EventWho'            = 'Who'
        'EventWhen'           = 'When'
        'EventRecordID'       = 'Record ID'
        'DomainController'    = 'Domain Controller'
        'Action'              = 'Action'
        'GroupName'           = ''
        'UserAffected'        = 'User Affected'
        'MemberName'          = ''
        'ComputerLockoutOn'   = ''
        'ReportedBy'          = ''
        'SamAccountName'      = ''
        'DisplayName'         = ''
        'UserPrincipalName'   = ''
        'HomeDirectory'       = ''
        'HomePath'            = ''
        'ScriptPath'          = ''
        'ProfilePath'         = ''
        'UserWorkstation'     = ''
        'PasswordLastSet'     = ''
        'AccountExpires'      = ''
        'PrimaryGroupId'      = ''
        'AllowedToDelegateTo' = ''
        'OldUacValue'         = ''
        'NewUacValue'         = ''
        'UserAccountControl'  = ''
        'UserParameters'      = ''
        'SidHistory'          = ''
        'LogonHours'          = ''
        'OperationType'       = ''
        'Message'             = ''
        'BackupPath'          = ''
        'LogType'             = ''
        'EventAdded'          = '<CurrentUserName>'
        'EventAddedWho'       = '<CurrentDateTime>'
    }

}
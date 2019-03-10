# Collects all named paramters (all others end up in $Args)
param(
    $eventid = 4729,
    $eventRecordID = 7488468, # 425358 ,
    $eventChannel,
    $eventSeverity
)

$ReportOptions = @{
    JustTestPrerequisite  = $false # runs testing without actually running script

    AsExcel               = $false # attaches Excel to email with all events, required ImportExcel module
    AsCSV                 = $false # attaches CSV to email with all events,
    AsHTML                = $true # puts exported data into email directly with all events
    SendMail              = $false
    OpenAsFile            = $true # requires AsHTML set to $true
    KeepReports           = $true # keeps files after reports are sent (only if AssExcel/AsCSV are in use)
    KeepReportsPath       = 'C:\Support\Reports\ExportedEvents' # if empty, temp path is used
    FilePattern           = 'Evotec-ADMonitoredEvents-<currentdate>.<extension>'
    FilePatternDateFormat = 'yyyy-MM-dd-HH_mm_ss'

    DisplayConsole        = @{
        ShowTime   = $true
        LogFile    = ''
        TimeFormat = 'yyyy-MM-dd HH:mm:ss'
    }
    Debug                 = @{
        DisplayTemplateHTML = $false
        Verbose             = $true
    }
    Notifications         = @{
        MicrosoftTeams = @{
            Use     = $true
            TeamsID = 'https://outlook.office.com/webhook/f0a1728bf5-4.....8'
        }
        Slack          = @{
            Use     = $false
            Channel = '#general'
            Uri     = ""
        }
        MSSQL          = @{
            Use                   = $true
            SqlServer             = 'EVOWIN'
            SqlDatabase           = 'SSAE18'
            SqlTable              = 'dbo.[Events]'
            # Left side is data in PSWinReporting. Right Side is ColumnName in SQL
            # Changing makes sense only for right side...
            SqlTableCreate        = $true
            SqlTableAlterIfNeeded = $true
            SqlCheckBeforeInsert  = 'EventRecordID', 'DomainController' # Based on column name
            
            SqlTableMapping       = [ordered] @{
                'Event ID'               = 'EventID,[int]'
                'Who'                    = 'EventWho'
                'When'                   = 'EventWhen,[datetime]'
                'Record ID'              = 'EventRecordID,[bigint]'
                'Domain Controller'      = 'DomainController'
                'Action'                 = 'Action'
                'Group Name'             = 'GroupName'
                'User Affected'          = 'UserAffected'
                'Member Name'            = 'MemberName'
                'Computer Lockout On'    = 'ComputerLockoutOn'
                'Reported By'            = 'ReportedBy'
                'SamAccountName'         = 'SamAccountName'
                'Display Name'           = 'DisplayName'
                'UserPrincipalName'      = 'UserPrincipalName'
                'Home Directory'         = 'HomeDirectory'
                'Home Path'              = 'HomePath'
                'Script Path'            = 'ScriptPath'
                'Profile Path'           = 'ProfilePath'
                'User Workstation'       = 'UserWorkstation'
                'Password Last Set'      = 'PasswordLastSet,[datetime]'
                'Account Expires'        = 'AccountExpires,[datetime]'
                'Primary Group Id'       = 'PrimaryGroupId'
                'Allowed To Delegate To' = 'AllowedToDelegateTo'
                'Old Uac Value'          = 'OldUacValue'
                'New Uac Value'          = 'NewUacValue'
                'User Account Control'   = 'UserAccountControl'
                'User Parameters'        = 'UserParameters'
                'Sid History'            = 'SidHistory'
                'Logon Hours'            = 'LogonHours'
                'OperationType'          = 'OperationType'
                'Message'                = 'Message'
                'Backup Path'            = 'BackupPath'
                'Log Type'               = 'LogType'
                'AddedWhen'              = 'EventAdded,[datetime],null' # ColumnsToTrack when it was added to database and by who / not part of event
                'AddedWho'               = 'EventAddedWho'  # ColumnsToTrack when it was added to database and by who / not part of event
                'Gathered From'          = 'GatheredFrom'
                'Gathered LogName'       = 'GatheredLogName'
            }
        }
    }
    Backup                = @{
        Use             = $false
        DestinationPath = 'E:\EventLogs'
    }
}
$ReportDefinitions = @{
    TimeToGenerate = $false

    ReportsAD      = @{
        Servers    = @{
            ForwardServer   = $env:COMPUTERNAME
            ForwardEventLog = 'ForwardedEvents'
        }
        EventBased = @{
            UserChanges            = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4720, 4738
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            UserStatus             = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4722, 4725, 4767, 4723, 4724, 4726
                LogName          = 'Security'
                IgnoreWords      = @{
                    'Domain Controller' = ''
                    'Action'            = ''
                    'User Affected'     = 'Win-*', '*AD1$*'
                    'Who'               = ''
                    'When'              = ''
                    'Event ID'          = ''
                    'Record ID'         = ''
                }
                ExportToSql      = @{
                    # per Event Category / Global SQL is above
                    Use                   = $true
                    SqlServer             = 'EVOWIN'
                    SqlDatabase           = 'SSAE18'
                    SqlTable              = 'dbo.[EventsUserStatus]'
                    # Left side is data in PSWinReporting. Right Side is ColumnName in SQL
                    # Changing makes sense only for right side...
                    SqlTableCreate        = $true
                    SqlTableAlterIfNeeded = $false # if table mapping is defined doesn't do anything
                    SqlCheckBeforeInsert  = 'EventRecordID', 'DomainController' # Based on column name
                    SqlTableMapping       = [ordered] @{
                        'Event ID'               = 'EventID,[int]'
                        'Who'                    = 'EventWho'
                        'When'                   = 'EventWhen,[datetime]'
                        'Record ID'              = 'EventRecordID,[bigint]'
                        'Domain Controller'      = 'DomainController'
                        'Action'                 = 'Action'
                        'Group Name'             = 'GroupName'
                        'User Affected'          = 'UserAffected'
                        'Member Name'            = 'MemberName'
                        'Computer Lockout On'    = 'ComputerLockoutOn'
                        'Reported By'            = 'ReportedBy'
                        'SamAccountName'         = 'SamAccountName'
                        'Display Name'           = 'DisplayName'
                        'UserPrincipalName'      = 'UserPrincipalName'
                        'Home Directory'         = 'HomeDirectory'
                        'Home Path'              = 'HomePath'
                        'Script Path'            = 'ScriptPath'
                        'Profile Path'           = 'ProfilePath'
                        'User Workstation'       = 'UserWorkstation'
                        'Password Last Set'      = 'PasswordLastSet,[datetime]'
                        'Account Expires'        = 'AccountExpires,[datetime]'
                        'Primary Group Id'       = 'PrimaryGroupId'
                        'Allowed To Delegate To' = 'AllowedToDelegateTo'
                        'Old Uac Value'          = 'OldUacValue'
                        'New Uac Value'          = 'NewUacValue'
                        'User Account Control'   = 'UserAccountControl'
                        'User Parameters'        = 'UserParameters'
                        'Sid History'            = 'SidHistory'
                        'Logon Hours'            = 'LogonHours'
                        'OperationType'          = 'OperationType'
                        'Message'                = 'Message'
                        'Backup Path'            = 'BackupPath'
                        'Log Type'               = 'LogType'
                        'AddedWhen'              = 'EventAdded,[datetime],null' # ColumnsToTrack when it was added to database and by who / not part of event
                        'AddedWho'               = 'EventAddedWho'  # ColumnsToTrack when it was added to database and by who / not part of event
                        #   'Gathered From'          = 'GatheredFrom'
                        #   'Gathered LogName'       = 'GatheredLogName'
                    }
                }
            }
            UserLockouts           = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4740
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            UserLogon              = @{
                Enabled          = $false
                EnabledSqlGlobal = $true
                Events           = 4624
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            UserLogonKerberos      = @{
                Enabled          = $false
                EnabledSqlGlobal = $true
                Events           = 4768
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            GroupMembershipChanges = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                LogName          = 'Security'
                IgnoreWords      = @{
                    'Who' = '*ANONYMOUS*'
                }
                ExportToSql      = @{
                    # per Event Category / Global SQL is above
                    Use                   = $true
                    SqlServer             = 'EVOWIN'
                    SqlDatabase           = 'SSAE18'
                    SqlTable              = 'dbo.[EventsGroupMembershipChanges]'
                    # Left side is data in PSWinReporting. Right Side is ColumnName in SQL
                    # Changing makes sense only for right side...
                    SqlTableCreate        = $true
                    SqlTableAlterIfNeeded = $false # if table mapping is defined doesn't do anything
                    SqlCheckBeforeInsert  = 'EventRecordID', 'DomainController' # Based on column name
                }
            }
            GroupCreateDelete      = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName          = 'Security'
                IgnoreWords      = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupPolicyChanges     = @{
                Enabled          = $false
                EnabledSqlGlobal = $true
                Events           = 5136, 5137, 5141
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            LogsClearedSecurity    = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 1102
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            LogsClearedOther       = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 104
                LogName          = 'System'
                IgnoreWords      = ''
            }
            EventsReboots          = @{
                Enabled          = $false
                EnabledSqlGlobal = $true
                Events           = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013
                LogName          = 'System'
                IgnoreWords      = ''
            }
            ComputerCreatedChanged = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4741, 4742 # created, changed
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            ComputerDeleted        = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4743 # deleted
                LogName          = 'Security'
                IgnoreWords      = ''
            }
        }
    }
}

Import-Module PSWinReporting -Force
Import-Module DBATools
Import-Module PSSharedGoods
Import-Module PSSlack
Import-Module PSTeams

$startNotificationsSplat = @{
    EventChannel      = $EventChannel
    EventID           = $EventID
    ReportDefinitions = $ReportDefinitions
    ReportOptions     = $ReportOptions
    EventRecordID     = $EventRecordID
}
Start-Notifications @startNotificationsSplat
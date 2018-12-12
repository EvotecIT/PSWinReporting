# Collects all named paramters (all others end up in $Args)
param(
    $eventid = 1105,
    $eventRecordID = 4621481195, # 425358 ,
    $eventChannel,
    $eventSeverity
)
Import-Module PSTeams
Import-Module PSEventViewer
Import-Module PSWinReporting -Force
Import-Module PSWriteColor
Import-Module PSSlack
Import-Module DBATools
Import-Module PSSharedGoods #-Force

$ReportOptions = @{
    JustTestPrerequisite  = $false # runs testing without actually running script

    AsExcel               = $true # attaches Excel to email with all events, required PSWriteExcel module
    AsCSV                 = $false # attaches CSV to email with all events,
    AsHTML                = $true # puts exported data into email directly with all events
    SendMail              = $false
    OpenAsFile            = $true # requires AsHTML set to $true
    KeepReports           = $true # keeps files after reports are sent (only if AssExcel/AsCSV are in use)
    KeepReportsPath       = 'C:\Support\Reports\ExportedEvents' # if empty, temp path is used
    FilePattern           = 'Evotec-ADMonitoredEvents-<currentdate>.<extension>'
    FilePatternDateFormat = 'yyyy-MM-dd-HH_mm_ss'

    DisplayConsole        = @{
        ShowTime   = $false
        LogFile    = 'C:\testing.log'
        TimeFormat = 'yyyy-MM-dd HH:mm:ss'
    }
    Debug                 = @{
        DisplayTemplateHTML = $false
        Verbose             = $false
    }
    Notifications         = @{
        MicrosoftTeams = @{
            Use     = $false
            TeamsID = ''
        }
        Slack          = @{
            Use     = $false
            Channel = '#general'
            Uri     = ""
        }
        MSSQL          = @{
            Use                   = $false
            SqlServer             = 'EVO1'
            SqlDatabase           = 'SSAE18'
            SqlTable              = 'dbo.[Events]'
            # Left side is data in PSWinReporting. Right Side is ColumnName in SQL
            # Changing makes sense only for right side...
            SqlTableCreate        = $true
            SqlTableAlterIfNeeded = $true
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
            }
        }
    }
    Backup                = @{
        Use             = $true
        DestinationPath = 'C:\MyEvents\'
    }
}
$ReportDefinitions = @{
    TimeToGenerate = $false
    TeamsID        = ''

    ReportsAD      = @{
        Servers    = @{
            ForwardServer   = $env:COMPUTERNAME
            ForwardEventLog = 'ForwardedEvents'
        }
        EventBased = @{
            UserChanges            = @{
                Enabled     = $true
                Events      = 4720, 4738
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserStatus             = @{
                Enabled     = $true
                Events      = 4722, 4725, 4767, 4723, 4724, 4726
                LogName     = 'Security'
                IgnoreWords = @{
                    'Domain Controller' = ''
                    'Action'            = ''
                    'User Affected'     = 'Win-*', '*AD1$*'
                    'Who'               = ''
                    'When'              = ''
                    'Event ID'          = ''
                    'Record ID'         = ''
                }
            }
            UserLockouts           = @{
                Enabled     = $true
                Events      = 4740
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserLogon              = @{
                Enabled     = $false
                Events      = 4624
                LogName     = 'Security'
                IgnoreWords = ''
            }
            ComputerCreatedChanged = @{
                Enabled     = $true
                Events      = 4741, 4742 # created, changed
                LogName     = 'Security'
                IgnoreWords = ''
            }
            ComputerDeleted        = @{
                Enabled     = $true
                Events      = 4743 # deleted
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserLogonKerberos      = @{
                Enabled     = $false
                Events      = 4768
                LogName     = 'Security'
                IgnoreWords = ''
            }
            GroupMembershipChanges = @{
                Enabled     = $true
                Events      = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupCreateDelete      = @{
                Enabled     = $true
                Events      = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupPolicyChanges     = @{
                Enabled     = $false
                Events      = 5136, 5137, 5141
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedSecurity    = @{
                Enabled     = $true
                Events      = 1102, 1105
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedOther       = @{
                Enabled     = $true
                Events      = 104
                LogName     = 'System'
                IgnoreWords = ''
            }
            EventsReboots          = @{
                Enabled     = $false
                Events      = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013
                LogName     = 'System'
                IgnoreWords = ''
            }
        }
    }
}

$LoggerParameters = @{
    ShowTime   = $true
    LogsDir    = 'C:\temp\logs'
    TimeFormat = 'yyyy-MM-dd HH:mm:ss'
}

Start-Notifications -ReportDefinitions $ReportDefinitions -ReportOptions $ReportOptions -EventID $EventID -EventRecordID $EventRecordID -EventChannel $EventChannel -LoggerParameters $LoggerParameters
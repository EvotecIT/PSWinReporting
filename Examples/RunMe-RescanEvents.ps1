<#
Update-Module PSEventViewer
Update-Module PSWinReporting
Update-Module PSWriteColor
Update-Module PSWriteExcel
Update-Module DBATools
#>
Import-Module PSEventViewer
Import-Module PSWinReporting -Force
Import-Module PSWriteColor
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
    RescanFiles           = [ordered] @{
        Directories = [ordered] @{
            MyEvents     = 'C:\MyEvents' #
            MyOtherEvent = 'C:\MyEvent1'
        }
        Files       = [ordered] @{
            File1 = 'C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx'
        }
    }
    Notifications         = [ordered] @{
        MicrosoftTeams = [ordered] @{
            Use     = $false
            TeamsID = ''
        }
        Slack          = [ordered] @{
            Use     = $false
            Channel = '#general'
            Uri     = ""
        }
        MSSQL          = [ordered] @{
            Use                   = $true
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
$ReportTimes = @{
    # Report Per Hour
    PastHour             = $false # if it's 23:22 it will report 22:00 till 23:00
    CurrentHour          = $false # if it's 23:22 it will report 23:00 till 00:00
    # Report Per Day
    PastDay              = $false # if it's 1.04.2018 it will report 31.03.2018 00:00:00 till 01.04.2018 00:00:00
    CurrentDay           = $false # if it's 1.04.2018 05:22 it will report 1.04.2018 00:00:00 till 01.04.2018 00:00:00
    # Report Per Week
    OnDay                = @{
        Enabled = $false
        Days    = 'Monday'#, 'Tuesday'
    }
    # Report Per Month
    PastMonth            = @{
        Enabled = $false # checks for 1st day of the month - won't run on any other day unless used force
        Force   = $false  # if true - runs always ...
    }
    CurrentMonth         = $false

    # Report Per Quarter
    PastQuarter          = @{
        Enabled = $false # checks for 1st day fo the quarter - won't run on any other day
        Force   = $false
    }
    CurrentQuarter       = $false
    # Report Custom
    CurrentDayMinusDayX  = @{
        Enabled = $false
        Days    = 7    # goes back X days and shows just 1 day
    }
    CurrentDayMinuxDaysX = @{
        Enabled = $false
        Days    = 3 # goes back X days and shows X number of days till Today
    }
    CustomDate           = @{
        Enabled  = $false
        DateFrom = get-date -Year 2018 -Month 03 -Day 19
        DateTo   = get-date -Year 2018 -Month 03 -Day 23
    }
    Everything           = $true
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

Start-RescanEvents -ReportDefinitions $ReportDefinitions -ReportOptions $ReportOptions -ReportTimes $ReportTimes
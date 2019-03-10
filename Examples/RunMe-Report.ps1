$EmailParameters = @{
    EmailFrom                   = "notifications@domain.com"
    EmailTo                     = "przemyslaw.klys@domain.com, admin@domain.com"
    EmailCC                     = ""
    EmailBCC                    = ""
    EmailReplyTo                = ""
    EmailServer                 = "smtp.office365.com"
    EmailServerPassword         = "YourPassword"
    EmailServerPasswordAsSecure = $false
    EmailServerPasswordFromFile = $false
    EmailServerPort             = "587"
    EmailServerLogin            = "notifications@domain.com"
    EmailServerEnableSSL        = 1
    EmailEncoding               = "Unicode"
    EmailSubject                = "[Reporting] Event Changes for period <<DateFrom>> to <<DateTo>>"
    EmailPriority               = "Low" # Normal, High
}
$FormattingParameters = @{
    CompanyBranding        = @{
        Logo   = 'https://evotec.xyz/wp-content/uploads/2015/05/Logo-evotec-012.png'
        Width  = '200'
        Height = ''
        Link   = 'https://evotec.xyz'
        Inline = $false
    }
    FontFamily             = 'Calibri Light'
    FontSize               = '9pt'
    FontHeadingFamily      = 'Calibri Light'
    FontHeadingSize        = '12pt'

    FontTableHeadingFamily = 'Calibri Light'
    FontTableHeadingSize   = '9pt'

    FontTableDataFamily    = 'Calibri Light'
    FontTableDataSize      = '9pt'

    Colors                 = @{
        # case sensitive
        Red   = 'removed', 'deleted', 'locked out', 'lockouts', 'disabled', 'Domain Admins', 'was cleared'
        Blue  = 'changed', 'changes', 'change', 'reset'
        Green = 'added', 'enabled', 'unlocked', 'created'
    }
    Styles                 = @{
        # case sensitive
        B = 'status', 'Domain Admins', 'Enterprise Admins', 'Schema Admins', 'was cleared', 'lockouts' # BOLD
        I = '' # Italian
        U = 'status'# Underline
    }
    Links                  = @{

    }
}
$ReportOptions = @{
    JustTestPrerequisite  = $false # runs testing without actually running script

    AsExcel               = $false # attaches Excel to email with all events, required ImportExcel module
    AsCSV                 = $false # attaches CSV to email with all events,
    AsHTML                = $true # puts exported data into email directly with all events
    SendMail              = $false
    OpenAsFile            = $true
    KeepReports           = $true # keeps files after reports are sent (only if AssExcel/AsCSV are in use)
    KeepReportsPath       = "C:\Support\Reports\ExportedEvents" # if empty, temp path is used
    FilePattern           = "Evotec-<currentdate>.<extension>"
    FilePatternDateFormat = "yyyy-MM-dd-HH_mm_ss"
    RemoveDuplicates      = $true #

    AsSql                 = @{
        Use                   = $true
        SqlServer             = 'EVOWIN'
        SqlDatabase           = 'SSAE18'
        SqlTable              = 'dbo.[Events]'
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
            'Gathered From'          = 'GatheredFrom'
            'Gathered LogName'       = 'GatheredLogName'
        }
    }


    DisplayConsole        = @{
        ShowTime   = $true
        LogFile    = "$Env:USERPROFILE\Desktop\PSWinReporting-Manual.log"
        TimeFormat = "yyyy-MM-dd HH:mm:ss"
    }
    Debug                 = @{
        DisplayTemplateHTML = $false
        Verbose             = $false
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
    CurrentMonth         = $true

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
    Everything           = $false
}
$ReportDefinitions = @{
    TimeToGenerate = $false

    ReportsAD      = @{
        Servers           = @{
            UseForwarders   = $true # if $true skips Automatic/OnlyPDC/DC for reading logs. However it uses Automatic to deliver size of logs so keep Automatic to $true
            ForwardServer   = $ENV:COMPUTERNAME
            ForwardEventLog = 'ForwardedEvents'

            UseDirectScan   = $true
            Automatic       = $true
            OnlyPDC         = $false
            DC              = ''
        }
        ArchiveProcessing = @{
            Use         = $false
            Directories = [ordered] @{
                Use      = $false
                MyEvents = 'E:\EventLogs' #
                #MyOtherEvent = 'C:\MyEvent1'
            }
            Files       = [ordered] @{
                Use = $false
                #File1 = 'E:\EventLogs\Archive-Security-2018-09-14-22-13-07-710.evtx'
            }
        }
        EventBased        = @{
            UserChanges            = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4720, 4738
                LogName          = 'Security'
                IgnoreWords      = @{}
            }
            UserStatus             = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4722, 4725, 4767, 4723, 4724, 4726
                LogName          = 'Security'
                IgnoreWords      = @{}
                ExportToSql      = @{
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
                IgnoreWords      = @{}
            }
            UserLogon              = @{
                Enabled          = $false
                EnabledSqlGlobal = $true
                Events           = 4624
                LogName          = 'Security'
                IgnoreWords      = @{}
            }
            GroupMembershipChanges = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                LogName          = 'Security'
                IgnoreWords      = @{}
            }
            GroupCreateDelete      = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName          = 'Security'
                IgnoreWords      = @{}
            }
            GroupPolicyChanges     = @{
                Enabled          = $false
                EnabledSqlGlobal = $true
                Events           = 5136, 5137, 5141
                LogName          = 'Security'
                IgnoreWords      = @{}
            }
            LogsClearedSecurity    = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 1102
                LogName          = 'Security'
                IgnoreWords      = @{}
                ExportToSql      = @{
                    Use                   = $false
                    SqlServer             = 'EVO1'
                    SqlDatabase           = 'SSAE18'
                    SqlTable              = 'dbo.[EventsLogsClearedSecurity]'
                    SqlTableCreate        = $true
                    SqlTableAlterIfNeeded = $false # if table mapping is defined doesn't do anything
                    SqlCheckBeforeInsert  = 'EventRecordID', 'DomainController' # Based on column nameg
                }
            }
            LogsClearedOther       = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 104
                LogName          = 'System' # Source: EventLog, Task: 'Log clear'
                IgnoreWords      = @{}
            }
            EventsReboots          = @{
                Enabled          = $false
                EnabledSqlGlobal = $true
                Events           = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013
                LogName          = 'System'
                IgnoreWords      = @{}
            }
            ComputerCreatedChanged = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4741, 4742 # created, changed
                LogName          = 'Security'
                IgnoreWords      = @{}
            }
            ComputerDeleted        = @{
                Enabled          = $true
                EnabledSqlGlobal = $true
                Events           = 4743 # deleted
                LogName          = 'Security'
                IgnoreWords      = @{}
            }
        }
        Custom            = @{
            EventLogSize = @{
                Enabled          = $true
                EnabledSqlGlobal = $false
                Logs             = 'Security', 'Application', 'System'
                SortBy           = ''
            }
            ServersData  = @{
                Enabled          = $true
                EnabledSqlGlobal = $false
            }
            FilesData    = @{
                Enabled = $true
            }
        }
    }
}

Import-Module PSWinReporting -Force

### Starts Module (Requires config above)
$startADReportingSplat = @{
    ReportDefinitions    = $ReportDefinitions
    ReportTimes          = $ReportTimes
    FormattingParameters = $FormattingParameters
    ReportOptions        = $ReportOptions
    EmailParameters      = $EmailParameters
}
Start-ADReporting @startADReportingSplat
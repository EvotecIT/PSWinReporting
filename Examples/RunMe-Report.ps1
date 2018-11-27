Import-Module PSWinReporting -Force
Import-Module PSSharedGoods -Force
Import-Module PSEventViewer -Force

$LoggerParameters = @{
    ShowTime   = $true
    LogsDir    = 'C:\temp\logs'
    TimeFormat = 'yyyy-MM-dd HH:mm:ss'
}
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

    AsExcel               = $true # attaches Excel to email with all events, required PSWriteExcel module
    AsCSV                 = $false # attaches CSV to email with all events,
    AsHTML                = $true # puts exported data into email directly with all events
    SendMail              = $false
    OpenAsFile            = $true # requires AsHTML set to $true
    KeepReports           = $true # keeps files after reports are sent (only if AssExcel/AsCSV are in use)
    KeepReportsPath       = 'C:\Support\Reports\ExportedEvents' # if empty, temp path is used
    FilePattern           = 'Evotec-ADMonitoredEvents-<currentdate>.<extension>'
    FilePatternDateFormat = 'yyyy-MM-dd-HH_mm_ss'
    RemoveDuplicates      = $true #

    AsSql                 = @{
        Use                   = $true
        SqlServer             = 'EVO1'
        SqlDatabase           = 'SSAE18'
        SqlTable              = 'dbo.[Events]'
        # Left side is data in PSWinReporting. Right Side is ColumnName in SQL
        # Changing makes sense only for right side...
        SqlTableCreate        = $true
        SqlTableAlterIfNeeded = $false # if table mapping is defined doesn't do anything
        SqlCheckBeforeInsert  = 'EventRecordID' # Based on column name


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
            ForwardServer   = 'EVO1'
            ForwardEventLog = 'ForwardedEvents'

            UseDirectScan   = $true
            Automatic       = $true # will use all DCs for a forest
            OnlyPDC         = $false # will use PDC of current domain returned by Get-ADDomain
            DC              = ''
        }
        ArchiveProcessing = @{
            Use         = $true
            Directories = [ordered] @{
                #MyEvents = 'C:\MyEvents' #
                #MyOtherEvent = 'C:\MyEvent1'
            }
            Files       = [ordered] @{
                #File1 = 'C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx'
            }
        }
        EventBased        = @{
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
                    Use                   = $true
                    SqlServer             = 'EVO1'
                    SqlDatabase           = 'SSAE18'
                    SqlTable              = 'dbo.[EventsUserStatus]'
                    # Left side is data in PSWinReporting. Right Side is ColumnName in SQL
                    # Changing makes sense only for right side...
                    SqlTableCreate        = $true
                    SqlTableAlterIfNeeded = $false # if table mapping is defined doesn't do anything
                    SqlCheckBeforeInsert  = 'EventRecordID'
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
                EnabledSqlGlobal = $false
                Events           = 4740
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            ComputerCreatedChanged = @{
                Enabled          = $true
                EnabledSqlGlobal = $false
                Events           = 4741, 4742 # created, changed
                LogName          = 'Security'
                IgnoreWords      = ''
            }
            ComputerDeleted        = @{
                Enabled     = $true
                Events      = 4743 # deleted
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserLogon              = @{
                Enabled     = $false # do not set to TRUE (takes days to scan)
                Events      = 4624
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserLogonKerberos      = @{
                Enabled     = $false # do not set to TRUE. Didn't have any good results
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
                Enabled     = $false # not ready
                Events      = 5136, 5137, 5141
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedSecurity    = @{
                Enabled     = $true
                Events      = 1102, 1105
                LogName     = 'Security'
                IgnoreWords = ''
                ExportToSql = @{
                    Use                   = $true
                    SqlServer             = 'EVO1'
                    SqlDatabase           = 'SSAE18'
                    SqlTable              = 'dbo.[EventsLogsClearedSecurity]'
                    SqlTableCreate        = $true
                    SqlTableAlterIfNeeded = $true
                    SqlCheckBeforeInsert  = 'RecordID' # column name (generally 'Record ID') - SQL command removes spaces when not using TableMapping
                }
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
        Custom            = @{
            EventLogSize = @{
                Enabled = $true
                Logs    = 'Security', 'Application', 'System'
                SortBy  = ''
            }
            ServersData  = @{
                Enabled = $true
            }
            FilesData    = @{
                Enabled = $true
            }
        }
    }
}

$Params = @{
	EmailParameters      = $EmailParameters
	FormattingParameters = $FormattingParameters
	ReportOptions        = $ReportOptions
	ReportTimes          = $ReportTimes
	ReportDefinitions    = $ReportDefinitions
	LoggerParameters     = $LoggerParameters
}
Start-ADReporting @Params

$EmailParameters = @{
    EmailFrom            = "notifications@domain.com"
    EmailTo              = "przemyslaw.klys@domain.com, admin@domain.com"
    EmailCC              = ""
    EmailBCC             = ""
    EmailReplyTo         = ""
    EmailServer          = "smtp.office365.com"
    EmailServerPassword  = "YourPassword"
    EmailServerPort      = "587"
    EmailServerLogin     = "notifications@domain.com"
    EmailServerEnableSSL = 1
    EmailEncoding        = "Unicode"
    EmailSubject         = "[Reporting] Event Changes for period <<DateFrom>> to <<DateTo>>"
    EmailPriority        = "Low" # Normal, High
}
$FormattingParameters = @{
    CompanyBranding        = @{
        Logo   = 'https://evotec.xyz/wp-content/uploads/2015/05/Logo-evotec-012.png'
        Width  = '200'
        Height = ''
        Link   = 'https://evotec.xyz'
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

    DisplayConsole        = @{
        ShowTime   = $true
        LogFile    = ''
        TimeFormat = 'yyyy-MM-dd HH:mm:ss'
    }
    Debug                 = @{
        DisplayTemplateHTML = $false
        Verbose             = $true
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
}
$ReportDefinitions = @{
    TimeToGenerate = $false

    ReportsAD      = @{
        Servers    = @{
            UseForwarders   = $false # if $true skips Automatic/OnlyPDC/DC for reading logs. However it uses Automatic to deliver size of logs so keep Automatic to $true
            ForwardServer   = 'EVO1'
            ForwardEventLog = 'ForwardedEvents'

            Automatic       = $true # will use all DCs for a forest
            OnlyPDC         = $false # will use PDC of current domain returned by Get-ADDomain
            DC              = ''
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
                Enabled     = $true
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
        Custom     = @{
            EventLogSize = @{
                Enabled = $true
                Logs    = 'Security', 'Application', 'System'
                SortBy  = ''
            }
            ServersData  = @{
                Enabled = $true
            }
        }
    }
}

### Starts Module (Requires config above)
Clear-Host
Import-Module PSWinReporting -Force
Start-ADReporting -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportTimes $ReportTimes -ReportDefinitions $ReportDefinitions
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
    CompanyBranding   = @{
        Logo   = "https://evotec.xyz/wp-content/uploads/2015/05/Logo-evotec-012.png"
        Width  = "200"
        Height = ""
        Link   = "https://evotec.xyz"
    }
    FontFamily        = "Calibri Light"
    FontSize          = "9pt"
    FontHeadingFamily = "Calibri Light"
    FontHeadingSize   = "12pt"
}
$ReportOptions = @{
    JustTestPrerequisite  = $false # runs testing without actually running script
    IncludeTimeToGenerate = $false # report with time it takes to generate (need this for debugging)

    AsExcel               = $true # attaches Excel to email with all events, required ImportExcel module
    AsCSV                 = $false # attaches CSV to email with all events,
    AsHTML                = $true # puts exported data into email directly with all events
    SendMail              = $true
    OpenAsFile            = $true
    KeepReports           = $true # keeps files after reports are sent (only if AssExcel/AsCSV are in use)
    KeepReportsPath       = "C:\Support\Reports\ExportedEvents" # if empty, temp path is used
    FilePattern           = "Evotec-ADMonitoredEvents-<currentdate>.xlsx"
    FilePatternDateFormat = "yyyy-MM-dd-HH_mm_ss"

    DisplayConsole        = @{
        ShowTime   = $true
        LogFile    = ""
        TimeFormat = "yyyy-MM-dd HH:mm:ss"
    }
}

$ReportTimes = @{
    # Report Per Hour
    PastHour             = $false # if it's 23:22 it will report 22:00 till 23:00
    CurrentHour          = $false # if it's 23:22 it will report 23:00 till 00:00
    # Report Per Day
    PastDay              = $false # if it's 1.04.2018 it will report 31.03.2018 00:00:00 till 01.04.2018 00:00:00
    CurrentDay           = $true # if it's 1.04.2018 05:22 it will report 1.04.2018 00:00:00 till 01.04.2018 00:00:00
    # Report Per Week
    OnDay                = @{
        Enabled = $true
        Days    = '"Monday'#, 'Tuesday'
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
}

$ReportDefinitions = @{
    ReportsAD = @{
        Servers    = @{
            Automatic = $true
            OnlyPDC   = $false
            DC        = ''
        }
        EventBased = @{
            UserChanges            = @{
                Enabled = $false
                Events  = 4720, 4738
                LogName = 'Security'
            }
            UserStatus             = @{
                Enabled = $false
                Events  = 4722, 4725, 4767, 4723, 4724, 4726
                LogName = 'Security'
            }
            UserLockouts           = @{
                Enabled = $false
                Events  = 4740
                LogName = 'Security'
            }
            GroupMembershipChanges = @{
                Enabled = $false
                Events  = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                LogName = 'Security'
            }
            GroupCreateDelete      = @{
                Enabled = $false
                Events  = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName = 'Security'
            }
            UserLogon              = @{
                Enabled = $false
                Events  = 4624
                LogName = 'Security'
            }
            GroupPolicyChanges     = @{
                Enabled = $false
                Events  = 5136, 5137, 5141
                LogName = 'Security'
            }
            LogsClearedSecurity    = @{
                Enabled = $false
                Events  = 1102
                LogName = 'Security'
            }
            LogsClearedOther       = @{
                Enabled = $false
                Events  = 104
                LogName = 'System' # Source: EventLog, Task: 'Log clear'
            }
            EventsReboots          = @{
                Enabled = $false
                Events  = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013
                LogName = 'System'
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
Start-ADReporting -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions -ReportTimes $ReportTimes
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
    JustTestPrerequisite            = $false # runs testing without actually running script
    OnlyPrimaryDC                   = $false # usually should query all DC's but for testing can query just one (PrimaryDC)

    IncludeTimeToGenerate           = $true # report with time it takes to generate (need this for debugging)
    IncludeDomainControllers        = $true
    IncludeGroupEvents              = $true
    IncludeUserEvents               = $true
    IncludeUserStatuses             = $true
    IncludeUserLockouts             = $true
    IncludeGroupCreateDelete        = $true
    IncludeDomainControllersReboots = $false # A bit useless if I'm to be honest
    IncludeLogonEvents              = $false # DO NOT USE - NOT FINISHED
    IncludeGroupPolicyChanges       = $false # DO NOT USE - NOT FINISHED
    IncludeClearedLogs              = $false # DO NOT USE - NOT FINISHED
    IncludeEventLogSize             = @{
        Use    = $true
        Logs   = "Security"#, "Application"
        SortBy = ""
    }
    # Report Per Hour
    ReportPastHour                  = $false # if it's 23:22 it will report 22:00 till 23:00
    ReportCurrentHour               = $false # if it's 23:22 it will report 23:00 till 00:00
    # Report Per Day
    ReportPastDay                   = $false # if it's 1.04.2018 it will report 31.03.2018 00:00:00 till 01.04.2018 00:00:00
    ReportCurrentDay                = $false # if it's 1.04.2018 05:22 it will report 1.04.2018 00:00:00 till 01.04.2018 00:00:00
    # Report Per Week
    ReportOnDay                     = @{
        Use  = $true
        Days = '"Monday'#, 'Tuesday'
    }
    # Report Per Month
    ReportPastMonth                 = @{
        Use   = $true # checks for 1st day of the month - won't run on any other day unless used force
        Force = $false  # if true - runs always ...
    }
    ReportCurrentMonth              = $false

    # Report Per Quarter
    ReportPastQuarter               = @{
        Use   = $true # checks for 1st day fo the quarter - won't run on any other day
        Force = $false
    }
    ReportCurrentQuarter            = $false
    # Report Custom
    ReportCurrentDayMinusDayX       = @{
        Use  = $false
        Days = 7    # goes back X days and shows just 1 day
    }
    ReportCurrentDayMinuxDaysX      = @{
        Use  = $false
        Days = 3 # goes back X days and shows X number of days till Today
    }
    ReportCustomDate                = @{
        Use      = $false
        DateFrom = get-date -Year 2018 -Month 03 -Day 19
        DateTo   = get-date -Year 2018 -Month 03 -Day 23
    }

    # AsExcel requires Import-Module ImportExcel
    AsExcel                         = $true # attaches Excel to email with all events
    AsCSV                           = $false # attaches CSV to email with all events,
    AsHTML                          = $true # puts exported data into email directly with all events
    SendMail                        = $true
    KeepReports                     = $true # keeps files after reports are sent (only if AssExcel/AsCSV are in use)
    KeepReportsPath                 = "C:\Support\Reports\ExportedEvents" # if empty, temp path is used
    FilePattern                     = "Evotec-ADMonitoredEvents-<currentdate>.xlsx"
    FilePatternDateFormat           = "yyyy-MM-dd-HH_mm_ss"

    DisplayConsole                  = @{
        ShowTime   = $true
        LogFile    = ""
        TimeFormat = "yyyy-MM-dd HH:mm:ss"
    }
}

### Starts Module (Requires config above)
Clear-Host
Start-ADReporting $EmailParameters $ReportOptions $FormattingParameters
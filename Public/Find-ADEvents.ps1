function Find-ADEvents {
    [CmdLetBinding()]
    param(
        [ValidateSet(
            'UserChanges',
            'UserStatus',
            'UserLockouts',
            'UserLogon',
            'UserLogonKerberos',
            'ComputerCreatedChanged',
            'ComputerDeleted',
            'GroupMembershipChanges',
            'GroupCreateDelete',
            'GroupPolicyChanges',
            'LogsClearedSecurity',
            'LogsClearedOther',
            'EventsReboots'
        )]
        [string] $Report,
        [ValidateSet(
            'PastHour',
            'CurrentHour',
            'PastDay',
            'CurrentDay',
            'PastMonth',
            'CurrentMonth',
            'PastQuarter',
            'CurrentQuarter',
            'Last3days',
            'Last7days',
            'Last14days',
            'Everything'
        )]
        [string] $DatesRange,
        [DateTime] $DatesFrom,
        [DateTime] $DatesTo

    )

    $DefineReports = @(
        'UserChanges',
        'UserStatus',
        'UserLockouts',
        'UserLogon',
        'UserLogonKerberos',
        'ComputerCreatedChanged',
        'ComputerDeleted',
        'GroupMembershipChanges',
        'GroupCreateDelete',
        'GroupPolicyChanges',
        'LogsClearedSecurity',
        'LogsClearedOther',
        'EventsReboots'
    )

    $DefineDates = (
        'PastHour',
        'CurrentHour',
        'PastDay',
        'CurrentDay',
        'PastMonth',
        'CurrentMonth',
        'PastQuarter',
        'CurrentQuarter',
        'Last3days',
        'Last7days',
        'Last14days',
        'Everything'
    )

    $ReportTimes = @{
        # Report Per Hour
        PastHour             = @{
            Enabled = $false # if it's 23:22 it will report 22:00 till 23:00
        }
        CurrentHour          = @{
            Enabled = $false # if it's 23:22 it will report 23:00 till 00:00
        }
        # Report Per Day
        PastDay              = @{
            Enabled = $false # if it's 1.04.2018 it will report 31.03.2018 00:00:00 till 01.04.2018 00:00:00
        }
        CurrentDay           = @{
            Enabled = $false # if it's 1.04.2018 05:22 it will report 1.04.2018 00:00:00 till 01.04.2018 00:00:00
        }
        # Report Per Week
        OnDay                = @{
            Enabled = $false
            Days    = 'Monday'#, 'Tuesday'
        }
        # Report Per Month
        PastMonth            = @{
            Enabled = $false # checks for 1st day of the month - won't run on any other day unless used force
            Force   = $true  # if true - runs always ...
        }
        CurrentMonth         = @{
            Enabled = $false
        }

        # Report Per Quarter
        PastQuarter          = @{
            Enabled = $false # checks for 1st day fo the quarter - won't run on any other day
            Force   = $true
        }
        CurrentQuarter       = @{
            Enabled = $false
        }
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
        Last3days            = @{
            Enabled = $false
        }
        Last7days            = @{
            Enabled = $false
        }
        Last14days           = @{
            Enabled = $false

        }
        Everything           = @{
            Enabled = $false
        }
    }

    $ReportTimes.$DatesRange.Enabled = $true


    ## Logging
    $LoggerParameters = @{
        ShowTime   = $false
        LogsDir    = ''
        TimeFormat = 'yyyy-MM-dd HH:mm:ss'
    }
    $Params = @{
        LogPath    = if ([string]::IsNullOrWhiteSpace($LoggerParameters.LogsDir)) { '' } else { Join-Path $LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log" }
        ShowTime   = $LoggerParameters.ShowTime
        TimeFormat = $LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params
    ##


    if (-not $Report) {
        $Logger.AddWarningRecord("You need to choose report type: $($DefineReports -join ', ')")
        return
    }

    ## Define reports
    $ReportDefinitions = @{
        ReportsAD = @{
            EventBased = @{
                UserChanges            = @{
                    Enabled     = $false
                    Events      = 4720, 4738
                    LogName     = 'Security'
                    IgnoreWords = ''
                }
                UserStatus             = @{
                    Enabled     = $false
                    Events      = 4722, 4725, 4767, 4723, 4724, 4726
                    LogName     = 'Security'
                    IgnoreWords = ''
                }
                UserLockouts           = @{
                    Enabled     = $false
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
                    Enabled     = $false
                    Events      = 4741, 4742 # created, changed
                    LogName     = 'Security'
                    IgnoreWords = ''
                }
                ComputerDeleted        = @{
                    Enabled     = $false
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
                    Enabled     = $false
                    Events      = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                    LogName     = 'Security'
                    IgnoreWords = @{
                        'Who' = '*ANONYMOUS*'
                    }
                }
                GroupCreateDelete      = @{
                    Enabled     = $false
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
                    Enabled     = $false
                    Events      = 1102, 1105
                    LogName     = 'Security'
                    IgnoreWords = ''
                }
                LogsClearedOther       = @{
                    Enabled     = $false
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




    $LogName = $ReportDefinitions.ReportsAD.EventBased.$Report.LogName
    $EventID = $ReportDefinitions.ReportsAD.EventBased.$Report.Events
    $ReportDefinitions.ReportsAD.EventBased.$Report.Enabled = $true

    ##
    $ServersAD = Get-DC
    $Servers = ($ServersAD | Where-Object { $_.'Host Name' -ne 'N/A' }).'Host Name'

    $Events = New-ArrayList
    $Dates = Get-ChoosenDates -ReportTimes $ReportTimes

    foreach ($Date in $Dates) {
        $Logger.AddInfoRecord("Getting events for dates $($Date.DateFrom) to $($Date.DateTo)")
        $FoundEvents = Get-Events -Server $Servers -LogName $LogName -EventID $EventID -DateFrom $Date.DateFrom -DateTo $Date.DateTo
        Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
        $Logger.AddInfoRecord("Events found $(Get-ObjectCount -Object $FoundEvents)")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running User Changes Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-UserChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserChanges.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending User Changes Report" )
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running User Statuses Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-UserStatuses -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserStatus.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserStatus.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending User Statuses Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Computer Created / Changed Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-ComputerChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.IgnoreWords
        $script:TimeToGenerateReports.Reports.ComputerCreatedChanged.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Computer Created / Changed Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Computer Deleted Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-ComputerStatus -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.IgnoreWords
        $script:TimeToGenerateReports.Reports.ComputerDeleted.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Computer Deleted Report")
    }
    If ($ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running User Lockouts Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-UserLockouts -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLockouts.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLockouts.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending User Lockouts Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Logon Events Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-LogonEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogon.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLogon.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Logon Events Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Logon Events (Kerberos) Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-LogonEventsKerberos -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLogonKerberos.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Logon Events (Kerberos) Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Group Membership Changes Report")
        $ExecutionTime = Start-TimeLog # Timer St
        $PreparedEvents = Get-GroupMembershipChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupMembershipChanges.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Group Membership Changes Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Group Create/Delete Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-GroupCreateDelete -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupCreateDelete.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Group Create/Delete Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Reboot Events Report (Troubleshooting Only)")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-RebootEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.EventsReboots.IgnoreWords
        $script:TimeToGenerateReports.Reports.EventsReboots.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Reboot Events Report (Troubleshooting Only)")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Group Policy Changes Report")
        $ExecutionTime = Start-TimeLog # Timer
        $PreparedEvents = Get-GroupPolicyChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupPolicyChanges.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Group Policy Changes Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Who Cleared Logs Report")
        $ExecutionTime = Start-TimeLog # Timer Start
        $PreparedEvents = Get-EventLogClearedLogs -Events $Events -Type "Security" -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.IgnoreWords
        $script:TimeToGenerateReports.Reports.LogsClearedSecurity.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Who Cleared Logs Report")
    }
    if ($ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -eq $true) {
        $Logger.AddInfoRecord("Running Who Cleared Logs Report")
        $ExecutionTime = Start-TimeLog # Timer Start
        $PreparedEvents = Get-EventLogClearedLogs -Events $Events -Type "Other" -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.IgnoreWords
        $script:TimeToGenerateReports.Reports.LogsClearedOther.Total = Stop-TimeLog -Time $ExecutionTime
        $Logger.AddInfoRecord("Ending Who Cleared Logs Report")
    }
    return $PreparedEvents
}
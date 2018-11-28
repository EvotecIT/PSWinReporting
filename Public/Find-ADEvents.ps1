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

        [parameter(ParameterSetName = "DateRange")]
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

        [parameter(ParameterSetName = "DateManual")]
        [DateTime] $DateFrom,

        [parameter(ParameterSetName = "DateManual")]
        [DateTime] $DateTo

    )
    # Bring defaults
    $ReportTimes = $Script:ReportTimes
    $ReportDefinitions = $Script:ReportDefinitions
    $DefineReports = $Script:DefineReports
    $DefineDates = $Script:DefineDates

    ## Logging / Display to screen
    $Params = @{
        LogPath    = if ([string]::IsNullOrWhiteSpace($Script:LoggerParameters.LogsDir)) { '' } else { Join-Path $Script:LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log" }
        ShowTime   = $Script:LoggerParameters.ShowTime
        TimeFormat = $Script:LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params
    ##

    if (-not $Report) {
        $Logger.AddWarningRecord("You need to choose report type: $($DefineReports -join ', ')")
        return
    }

    switch ($PSCmdlet.ParameterSetName) {
        DateRange {
            $ReportTimes.$DatesRange.Enabled = $true
        }
        DateManual {
            if ($DateFrom -and $DateTo) {
                $ReportTimes.CustomDate.Enabled = $true
                $ReportTimes.CustomDate.DateFrom = $DateFrom
                $ReportTimes.CustomDate.DateTo = $DateTo
            } else {
                return
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
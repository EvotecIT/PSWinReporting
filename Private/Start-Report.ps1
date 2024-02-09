function Start-Report {
    [CmdletBinding()]
    param (
        [hashtable] $Dates,
        [hashtable] $EmailParameters,
        [hashtable] $FormattingParameters,
        [hashtable] $ReportOptions,
        [hashtable] $ReportDefinitions
    )

    $time = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
    # Declare variables
    $EventLogTable = @()
    $GroupsEventsTable = @()
    $UsersEventsTable = @()
    $UsersEventsStatusesTable = @()
    $UsersLockoutsTable = @()
    $ComputerChanges = @()
    $ComputerDeleted = @()
    $LogonEvents = @()
    $LogonEventsKerberos = @()
    $RebootEventsTable = @()
    $TableGroupPolicyChanges = @()
    $TableEventLogClearedLogs = @()
    # $ServersTable = @()
    $GroupCreateDeleteTable = @()
    $TableExecutionTimes = ''
    $TableEventLogFiles = @()

    Write-Color @script:WriteParameters '[i] Processing report for dates from: ', $Dates.DateFrom.ToString(), ' to ', $Dates.DateTo.ToString()  -Color White, Yellow, White, Yellow
    Write-Color @script:WriteParameters '[i] Establishing servers list to ', 'process...' -Color White, Yellow

    $ServersAD = Get-DC
    $Servers = Find-ServersAD -ReportDefinitions $ReportDefinitions -DC $ServersAD    #-OnlyPDC:$ReportDefinitions.ReportsAD.Servers.OnlyPDC -Automatic:$ReportDefinitions.ReportsAD.Servers.Automatic

    Write-Color @script:WriteParameters '[i] Preparing ', 'Security Events', ' list to be processed.' -Color White, Yellow, White
    $EventsToProcessSecurity = Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch 'Security'
    Write-Color @script:WriteParameters '[i] Preparing ', 'System Events', ' list to be processed.' -Color White, Yellow, White
    $EventsToProcessSystem = Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch 'System'

    $Events = @()
    if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
        Write-Color @script:WriteParameters '[i] Processing ', 'Forwarded Events', ' on forwarding servers: ', ($ReportDefinitions.ReportsAD.Servers.ForwardServer -join ', ') -Color White, Yellow, White

        foreach ($ForwardedServer in $ReportDefinitions.ReportsAD.Servers.ForwardServer) {
            #$Events += Get-Events -Server $ReportDefinitions.ReportsAD.ForwardServer -LogName $ReportDefinitions.ReportsAD.ForwardServer.ForwardEventLog
            $Events += Get-AllRequiredEvents -Servers $ForwardedServer -Dates $Dates -Events $EventsToProcessSecurity -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
            $Events += Get-AllRequiredEvents -Servers $ForwardedServer -Dates $Dates -Events $EventsToProcessSystem -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
        }
    }
    if ($ReportDefinitions.ReportsAD.Servers.UseDirectScan) {
        Write-Color @script:WriteParameters '[i] Processing ', 'Security Events', ' from directly scanned servers: ', ($Servers -Join ', ') -Color White, Yellow, White
        $Events += Get-AllRequiredEvents -Servers $Servers -Dates $Dates -Events $EventsToProcessSecurity -LogName 'Security' -Verbose:$ReportOptions.Debug.Verbose
        Write-Color @script:WriteParameters '[i] Processing ', 'System Events', ' from directly scanned servers: ', ($Servers -Join ', ') -Color White, Yellow, White
        $Events += Get-AllRequiredEvents -Servers $Servers -Dates $Dates -Events $EventsToProcessSystem -LogName 'System' -Verbose:$ReportOptions.Debug.Verbose
    }
    if ($ReportDefinitions.ReportsAD.ArchiveProcessing.Use) {
        $EventLogFiles = Get-CongfigurationEvents -Sections $ReportDefinitions.ReportsAD.ArchiveProcessing
        foreach ($File in $EventLogFiles) {
            $TableEventLogFiles += Get-FileInformation -File $File
            Write-Color @script:WriteParameters '[i] Processing ', 'Security Events', ' on file: ', $File -Color White, Yellow, White
            $Events += Get-AllRequiredEvents -FilePath $File -Dates $Dates -Events $EventsToProcessSecurity -LogName 'Security' -Verbose:$ReportOptions.Debug.Verbose
            Write-Color @script:WriteParameters '[i] Processing ', 'System Events', ' on file ', $File -Color White, Yellow, White
            $Events += Get-AllRequiredEvents -FilePath $File -Dates $Dates -Events $EventsToProcessSystem -LogName 'System' -Verbose:$ReportOptions.Debug.Verbose
        }
    }

    Write-Color @script:WriteParameters '[i] Processing ', 'Event Log Sizes', ' on defined servers for warnings.' -Color White, Yellow, White
    $EventLogDatesSummary = @()
    if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
        Write-Color @script:WriteParameters '[i] Processing ', 'Event Log Sizes', ' on ', ([string] $ReportDefinitions.ReportsAD.Servers.ForwardServer), ' for warnings.' -Color White, Yellow, White
        $EventLogDatesSummary += Get-EventLogSize -Servers $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
    }
    if ($ReportDefinitions.ReportsAD.Servers.UseDirectScan) {
        Write-Color @script:WriteParameters '[i] Processing ', 'Event Log Sizes', ' on ', ([string] $Servers), ' for warnings.' -Color White, Yellow, White
        $EventLogDatesSummary += Get-EventLogSize -Servers $Servers -LogName 'Security'
        $EventLogDatesSummary += Get-EventLogSize -Servers $Servers -LogName 'System'
    }
    Write-Color @script:WriteParameters '[i] Verifying ', 'Warnings', ' reported earlier.' -Color White, Yellow, White
    $Warnings = Invoke-EventLogVerification -Results $EventLogDatesSummary -Dates $Dates

    if ($ReportOptions.RemoveDuplicates) {
        Write-Color @script:WriteParameters '[i] Removing ', 'Duplicates', ' from all events. Current list contains ', $Events.Count, ' events.'  -Color White, Yellow, White, Green, White
        $Events = Remove-DuplicateObjects -Object $Events -Property 'RecordID'
        Write-Color @script:WriteParameters '[i] Removed ', 'Duplicates', '. Following ', $Events.Count, ' events will be analyzed further.'  -Color White, Yellow, White, Green, White
    }

    # Prepare email body
    $EmailBody = Set-EmailHead -FormattingOptions $FormattingParameters
    $EmailBody += Set-EmailReportBrading -FormattingParameters $FormattingParameters
    $EmailBody += Set-EmailReportDetails -FormattingParameters $FormattingParameters -Dates $Dates -Warnings $Warnings

    ### USER EVENTS STARTS ###
    if ($ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsTable = Get-UserChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsStatusesTable = Get-UserStatuses -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserStatus.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserStatus.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Computer Created / Changed Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $ComputerChanges = Get-ComputerChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.IgnoreWords
        $script:TimeToGenerateReports.Reports.ComputerCreatedChanged.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Computer Created / Changed Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Computer Deleted Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $ComputerDeleted = Get-ComputerStatus -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.IgnoreWords
        $script:TimeToGenerateReports.Reports.ComputerDeleted.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Computer Deleted Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersLockoutsTable = Get-UserLockouts -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLockouts.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLockouts.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $LogonEvents = Get-LogonEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogon.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLogon.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $LogonEventsKerberos = Get-LogonEventsKerberos -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLogonKerberos.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
    }
    ### USER EVENTS END ###

    if ($ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report" -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer St
        $GroupsEventsTable = Get-GroupMembershipChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupMembershipChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $GroupCreateDeleteTable = Get-GroupCreateDelete -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupCreateDelete.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $RebootEventsTable = Get-RebootEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.EventsReboots.IgnoreWords
        $script:TimeToGenerateReports.Reports.EventsReboots.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $TableGroupPolicyChanges = Get-GroupPolicyChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupPolicyChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogs = Get-EventLogClearedLogs -Events $Events -Type 'Security' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.IgnoreWords
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.LogsClearedSecurity.Total = Stop-TimeLog -Time $ExecutionTime
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogsOther = Get-EventLogClearedLogs -Events $Events -Type 'Other' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.IgnoreWords
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.LogsClearedOther.Total = Stop-TimeLog -Time $ExecutionTime
    }
    If ($ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer St
        if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
            foreach ($LogName in $ReportDefinitions.ReportsAD.Servers.ForwardEventLog) {
                Write-Color @script:WriteParameters "[i] Running ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
                $EventLogTable += Get-EventLogSize -Servers $ReportDefinitions.ReportsAD.Servers.ForwardServer  -LogName $LogName
                Write-Color @script:WriteParameters "[i] Ending ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
            }
        }
        foreach ($LogName in $ReportDefinitions.ReportsAD.Custom.EventLogSize.Logs) {
            Write-Color @script:WriteParameters "[i] Running ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
            $EventLogTable += Get-EventLogSize -Servers $Servers -LogName $LogName
            Write-Color @script:WriteParameters "[i] Ending ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
        }
        if ($ReportDefinitions.ReportsAD.Custom.EventLogSize.SortBy -ne "") { $EventLogTable = $EventLogTable | Sort-Object $ReportDefinitions.ReportsAD.Custom.EventLogSize.SortBy }
        $script:TimeToGenerateReports.Reports.EventLogSize.Total = Stop-TimeLog -Time $ExecutionTime
    }

    if ($ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {

        } else {
            #$ServersTable = Get-DomainControllers -Servers $Servers
        }
        $script:TimeToGenerateReports.Reports.ServersData.Total = Stop-TimeLog -Time $ExecutionTime
    }

    if ($ReportDefinitions.TimeToGenerate -eq $true) {
        $TableExecutionTimes = Set-TimeReports -HashTable $script:TimeToGenerateReports.Reports
    }

    # prepare body with HTML
    if ($ReportOptions.AsHTML) {
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.TimeToGenerate -ReportTable $TableExecutionTimes -ReportTableText 'Following report shows execution times' -Special
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportTable $ServersAD -ReportTableText 'Following AD servers were detected in forest'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.Custom.FilesData.Enabled -ReportTable $TableEventLogFiles -ReportTableText 'Following files have been processed for events'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportTable $EventLogTable -ReportTableText 'Following event log sizes were reported'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -ReportTable $UsersEventsTable -ReportTableText 'Following user changes happened'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -ReportTable $UsersEventsStatusesTable -ReportTableText 'Following user status happened'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -ReportTable $UsersLockoutsTable -ReportTableText 'Following user lockouts happened'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.Enabled -ReportTable $ComputerChanges -ReportTableText 'Following computer events happened'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Enabled -ReportTable $ComputerDeleted -ReportTableText 'Following computer delated events happened'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -ReportTable $LogonEvents -ReportTableText 'Following logon events happened'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -ReportTable $LogonEventsKerberos -ReportTableText 'Following logon (kerberos) events happened'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -ReportTable $GroupsEventsTable -ReportTableText 'The membership of those groups below has changed'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -ReportTable $GroupCreateDeleteTable -ReportTableText 'Following group creation/deletion occurred'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -ReportTable $TableGroupPolicyChanges -ReportTableText 'Following GPOs were modified'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -ReportTable $TableEventLogClearedLogs -ReportTableText 'Following logs clearing (security) actions occurred '
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -ReportTable $TableEventLogClearedLogsOther -ReportTableText 'Following logs clearing (other) actions occurred'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -ReportTable $RebootEventsTable -ReportTableText 'Following reboot related events happened'
    }
    $Reports = @()
    If ($ReportOptions.AsExcel) {
        $ReportFilePathXLSX = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension "xlsx"
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Processed Servers" -ReportTable $ServersAD
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Event log sizes" -ReportTable $EventLogTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "User Changes" -ReportTable $UsersEventsTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "User Status Changes" -ReportTable $UsersEventsStatusesTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "User Lockouts" -ReportTable $UsersLockoutsTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "Computer Status Changes" -ReportTable $ComputerChanges
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Computer Deleted" -ReportTable $ComputerDeleted
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "User Logon Events" -ReportTable $LogonEvents
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "User Logon Kerberos Events" -ReportTable $LogonEventsKerberos
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Membership Changes"  -ReportTable $GroupsEventsTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Creation Deletion Changes"  -ReportTable $GroupCreateDeleteTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Policy Changes" -ReportTable $TableGroupPolicyChanges
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Clear Log Events (Security)" -ReportTable $TableEventLogClearedLogs
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Clear Log Events (Other)" -ReportTable $TableEventLogClearedLogsOther
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Troubleshooting Reboots" -ReportTable $RebootEventsTable
        $Reports += $ReportFilePathXLSX
    }
    If ($ReportOptions.AsCSV) {
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportServers" -ReportTable $ServersAD
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportEventLogSize" -ReportTable $EventLogTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserEvents" -ReportTable $UsersEventsTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserStatuses" -ReportTable $UsersEventsStatusesTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserLockouts" -ReportTable $UsersLockoutsTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportComputerChanged" -ReportTable $ComputerChanges
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportComputerDeleted" -ReportTable $ComputerDeleted
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserLogons" -ReportTable $LogonEvents
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserLogonsKerberos" -ReportTable $LogonEventsKerberos
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupEvents" -ReportTable $GroupsEventsTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupCreateDeleteEvents" -ReportTable $GroupCreateDeleteTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupPolicyChanges" -ReportTable $TableGroupPolicyChanges
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "IncludeClearedLogsSecurity" -ReportTable $TableEventLogClearedLogs
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "IncludeClearedLogsOther" -ReportTable $TableEventLogClearedLogs
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportReboots" -ReportTable $RebootEventsTable
    }
    $Reports = $Reports |  Where-Object { $_ } | Sort-Object -Uniq

    # Do Cleanup of Emails
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateDays**' -ReplaceWith $time.Elapsed.Days
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateHours**' -ReplaceWith $time.Elapsed.Hours
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateMinutes**' -ReplaceWith $time.Elapsed.Minutes
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateSeconds**' -ReplaceWith $time.Elapsed.Seconds
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateMilliseconds**' -ReplaceWith $time.Elapsed.Milliseconds
    $EmailBody = Set-EmailFormatting -Template $EmailBody -FormattingParameters $FormattingParameters -ConfigurationParameters $ReportOptions
    $Time.Stop()

    #$script:TimeToGenerateReports | ConvertTo-Json

    # Sending email - finalizing package
    if ($ReportOptions.SendMail) {

        # This tests if there is at least one event in reports
        $Reporting = @( 
            $UsersEventsTable,
            $UsersEventsStatusesTable,
            $UsersLockoutsTable,
            $ComputerChanges, 
            $ComputerDeleted,
            $LogonEvents,
            $LogonEventsKerberos,
            $GroupsEventsTable,
            $GroupCreateDeleteTable,
            $TableGroupPolicyChanges,
            $TableEventLogClearedLogs,
            $TableEventLogClearedLogsOther,
            $RebootEventsTable
        )
        $AtleastOneEvent = $false
        foreach ($Table in $Reporting) {
            if ($null -ne $Table -and (Get-ObjectCount -Object $Table) -gt 0) {
                $AtleastOneEvent = $true
                break
            }
        }
        # Testing if sending is required
        if ($ReportOptions.SendMailOnlyOnEvents -eq $true -and $AtleastOneEvent -eq $false) {
            Write-Color @script:WriteParameters "[i] Sending email with reports... ", 'Skipped on demand. ', 'No events found.' -Color White, Yellow, Green
        } else {
            $TemporarySubject = $EmailParameters.EmailSubject -replace "<<DateFrom>>", "$($Dates.DateFrom.ToString())" -replace "<<DateTo>>", "$($Dates.DateTo.ToString())"
            Write-Color @script:WriteParameters "[i] Sending email with reports..." -Color White, Green -NoNewLine
            $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject
            if ($SendMail.Status) {
                Write-Color "Success!" -Color Green
            } else {
                Write-Color "Not working!" -Color Red
                Write-Color @script:WriteParameters "[i] Error: ", "$($SendMail.Error)" -Color White, Red
            }
        }
    } else {
        Write-Color @script:WriteParameters "[i] Skipping sending email with reports...", "as per configuration!" -Color White, Green
    }
    if ($ReportOptions.AsHTML) {
        $ReportHTMLPath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension 'html'
        try {
            $EmailBody | Out-File -Encoding unicode -FilePath $ReportHTMLPath        
            if ($ReportOptions.OpenAsFile) {
                Write-Color @script:WriteParameters '[i] Saving report to file ', $ReportHTMLPath, ' and opening it up...' -Color White, Yellow, White
                if (Test-Path $ReportHTMLPath) { Invoke-Item $ReportHTMLPath }
            } else {
                Write-Color @script:WriteParameters '[i] Saving report to file ', $ReportHTMLPath, '.' -Color White, Yellow, White
            }
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            Write-Collor @Script:WriteParameters "[e] Couldn't save file ", $ReportHTMLPath, '. Error: ', $ErrorMessage  -Color White, Yellow, White, Red
        }
    }


    #Write-Color @script:WriteParameters -Text '[i] ', 'Sending events to SQL' -Color White, White, Yellow
    #Export-ReportToSql -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $ReportOptions -ReportName "Processed Servers" -ReportTable $ServersAD
    #Export-ReportToSql -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $ReportOptions -ReportName "Event log sizes" -ReportTable $EventLogTable
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.UserChanges -ReportOptions $ReportOptions -ReportName  "User Changes" -ReportTable $UsersEventsTable
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.UserStatus -ReportOptions $ReportOptions -ReportName  "User Status Changes" -ReportTable $UsersEventsStatusesTable
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.UserLockouts -ReportOptions $ReportOptions -ReportName "User Lockouts" -ReportTable $UsersLockoutsTable
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged -ReportOptions $ReportOptions -ReportName  "Computer Status Changes" -ReportTable $ComputerChanges
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted -ReportOptions $ReportOptions -ReportName "Computer Deleted" -ReportTable $ComputerDeleted
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.UserLogon -ReportOptions $ReportOptions -ReportName "User Logon Events" -ReportTable $LogonEvents
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos -ReportOptions $ReportOptions -ReportName "User Logon Kerberos Events" -ReportTable $LogonEventsKerberos
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges -ReportOptions $ReportOptions -ReportName "Group Membership Changes"  -ReportTable $GroupsEventsTable
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete -ReportOptions $ReportOptions -ReportName "Group Creation Deletion Changes"  -ReportTable $GroupCreateDeleteTable
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges -ReportOptions $ReportOptions -ReportName "Group Policy Changes" -ReportTable $TableGroupPolicyChanges
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity -ReportOptions $ReportOptions -ReportName "Clear Log Events (Security)" -ReportTable $TableEventLogClearedLogs
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther -ReportOptions $ReportOptions -ReportName "Clear Log Events (Other)" -ReportTable $TableEventLogClearedLogsOther
    Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.EventsReboots -ReportOptions $ReportOptions -ReportName "Troubleshooting Reboots" -ReportTable $RebootEventsTable



    Remove-ReportsFiles -KeepReports $ReportOptions.KeepReports -AsExcel $ReportOptions.AsExcel -AsCSV $ReportOptions.AsCSV -ReportFiles $Reports
}
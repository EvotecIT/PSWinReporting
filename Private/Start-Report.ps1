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

	$Logger.AddInfoRecord("Processing report for dates from: $($Dates.DateFrom) to $($Dates.DateTo)")
	$Logger.AddInfoRecord('Establishing servers list to process...')

	$ServersAD = Get-DC
	$Servers = Find-ServersAD -ReportDefinitions $ReportDefinitions -DC $ServersAD

	$Logger.AddInfoRecord('Preparing Security Events list to be processed')
	$EventsToProcessSecurity = Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch 'Security'
	$Logger.AddInfoRecord('Preparing System Events list to be processed')
    $EventsToProcessSystem = Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch 'System'

    # Summary of events to process
    $Logger.AddInfoRecord("Found security events to process: $($EventsToProcessSecurity -join ', ')")
    $Logger.AddInfoRecord("Found system events to process: $($EventsToProcessSystem -join ', ')")

	$Events = New-ArrayList
	if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
		$Logger.AddInfoRecord("Preparing Forwarded Events on forwarding servers: $($ReportDefinitions.ReportsAD.Servers.ForwardServer -join ', ')")
		foreach ($ForwardedServer in $ReportDefinitions.ReportsAD.Servers.ForwardServer) {
			#$Events += Get-Events -Server $ReportDefinitions.ReportsAD.ForwardServer -LogName $ReportDefinitions.ReportsAD.ForwardServer.ForwardEventLog
			$FoundEvents = Get-AllRequiredEvents -Servers $ForwardedServer -Dates $Dates -Events $EventsToProcessSecurity -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
            Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
            $FoundEvents = Get-AllRequiredEvents -Servers $ForwardedServer -Dates $Dates -Events $EventsToProcessSystem -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
            Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
        }
	}
	if ($ReportDefinitions.ReportsAD.Servers.UseDirectScan) {
		$Logger.AddInfoRecord("Processing Security Events from directly scanned servers: $($Servers -Join ', ')")
        $FoundEvents = Get-AllRequiredEvents -Servers $Servers -Dates $Dates -Events $EventsToProcessSecurity -LogName 'Security' -Verbose:$ReportOptions.Debug.Verbose
        Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
		$Logger.AddInfoRecord("Processing System Events from directly scanned servers: $($Servers -Join ', ')")
        $FoundEvents = Get-AllRequiredEvents -Servers $Servers -Dates $Dates -Events $EventsToProcessSystem -LogName 'System' -Verbose:$ReportOptions.Debug.Verbose
        Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
	}
	if ($ReportDefinitions.ReportsAD.ArchiveProcessing.Use) {
		$EventLogFiles = Get-CongfigurationEvents -Sections $ReportDefinitions.ReportsAD.ArchiveProcessing
		foreach ($File in $EventLogFiles) {
			$TableEventLogFiles += Get-FileInformation -File $File
			$Logger.AddInfoRecord("Processing Security Events on file: $File")
            $FoundEvents = Get-AllRequiredEvents -FilePath $File -Dates $Dates -Events $EventsToProcessSecurity -LogName 'Security' -Verbose:$ReportOptions.Debug.Verbose
            Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
			$Logger.AddInfoRecord("Processing System Events on file: $File")
            $FoundEvents = Get-AllRequiredEvents -FilePath $File -Dates $Dates -Events $EventsToProcessSystem -LogName 'System' -Verbose:$ReportOptions.Debug.Verbose
            Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
		}
	}

	$Logger.AddInfoRecord('Processing Event Log Sizes on defined servers for warnings')
	$EventLogDatesSummary = @()
	if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
		$Logger.AddInfoRecord("Processing Event Log Sizes on $($ReportDefinitions.ReportsAD.Servers.ForwardServer) for warnings")
		$EventLogDatesSummary += Get-EventLogSize -Servers $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
	}
	if ($ReportDefinitions.ReportsAD.Servers.UseDirectScan) {
		$Logger.AddInfoRecord("Processing Event Log Sizes on $($Servers -Join ', ') for warnings")
		$EventLogDatesSummary += Get-EventLogSize -Servers $Servers -LogName 'Security'
		$EventLogDatesSummary += Get-EventLogSize -Servers $Servers -LogName 'System'
	}
	$Logger.AddInfoRecord('Verifying Warnings reported earlier')
	$Warnings = Invoke-EventLogVerification -Results $EventLogDatesSummary -Dates $Dates

	if ($ReportOptions.RemoveDuplicates) {
        $Logger.AddInfoRecord("Removing Duplicates from all events. Current list contains $(Get-ObjectCount -Object $Events) events")
        $Events = Remove-DuplicateObjects -Object $Events -Property 'RecordID'
		$Logger.AddInfoRecord("Removed Duplicates Following $(Get-ObjectCount -Object $Events) events will be analyzed further")
	}

	$Logger.AddInfoRecord('Processing User Events')
	if ($ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running User Changes Report')
		$ExecutionTime = Start-TimeLog # Timer
		$UsersEventsTable = Get-UserChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserChanges.IgnoreWords
		$script:TimeToGenerateReports.Reports.UserChanges.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending User Changes Report')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running User Statuses Report')
		$ExecutionTime = Start-TimeLog # Timer
		$UsersEventsStatusesTable = Get-UserStatuses -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserStatus.IgnoreWords
		$script:TimeToGenerateReports.Reports.UserStatus.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending User Statuses Report')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Computer Created / Changed Report')
		$ExecutionTime = Start-TimeLog # Timer
		$ComputerChanges = Get-ComputerChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.ComputerCreatedChanged.IgnoreWords
		$script:TimeToGenerateReports.Reports.ComputerCreatedChanged.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Computer Created / Changed Report')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Computer Deleted Report')
		$ExecutionTime = Start-TimeLog # Timer
		$ComputerDeleted = Get-ComputerStatus -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.IgnoreWords
		$script:TimeToGenerateReports.Reports.ComputerDeleted.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Computer Deleted Report')
	}
	If ($ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running User Lockouts Report')
		$ExecutionTime = Start-TimeLog # Timer
		$UsersLockoutsTable = Get-UserLockouts -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLockouts.IgnoreWords
		$script:TimeToGenerateReports.Reports.UserLockouts.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending User Lockouts Report')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Logon Events Report')
		$ExecutionTime = Start-TimeLog # Timer
		$LogonEvents = Get-LogonEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogon.IgnoreWords
		$script:TimeToGenerateReports.Reports.UserLogon.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Logon Events Report')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Logon Events (Kerberos) Report')
		$ExecutionTime = Start-TimeLog # Timer
		$LogonEventsKerberos = Get-LogonEventsKerberos -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.IgnoreWords
		$script:TimeToGenerateReports.Reports.UserLogonKerberos.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Logon Events (Kerberos) Report')
	}

    $Logger.AddInfoRecord('Processing Group Events')
	if ($ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Group Membership Changes Report')
		$ExecutionTime = Start-TimeLog # Timer St
		$GroupsEventsTable = Get-GroupMembershipChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.IgnoreWords
		$script:TimeToGenerateReports.Reports.GroupMembershipChanges.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Group Membership Changes Report')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Group Create/Delete Report')
		$ExecutionTime = Start-TimeLog # Timer
		$GroupCreateDeleteTable = Get-GroupCreateDelete -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.IgnoreWords
		$script:TimeToGenerateReports.Reports.GroupCreateDelete.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Group Create/Delete Report')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Reboot Events Report (Troubleshooting Only)')
		$ExecutionTime = Start-TimeLog # Timer
		$RebootEventsTable = Get-RebootEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.EventsReboots.IgnoreWords
		$script:TimeToGenerateReports.Reports.EventsReboots.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Reboot Events Report (Troubleshooting Only)')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Group Policy Changes Report')
		$ExecutionTime = Start-TimeLog # Timer
		$TableGroupPolicyChanges = Get-GroupPolicyChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.IgnoreWords
		$script:TimeToGenerateReports.Reports.GroupPolicyChanges.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Group Policy Changes Report')
    }
    $Logger.AddInfoRecord('Processing log clearing events')
	if ($ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Who Cleared Logs Report')
		$ExecutionTime = Start-TimeLog # Timer Start
		$TableEventLogClearedLogs = Get-EventLogClearedLogs -Events $Events -Type 'Security' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.IgnoreWords
		$script:TimeToGenerateReports.Reports.LogsClearedSecurity.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Who Cleared Logs Report')
	}
	if ($ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -eq $true) {
		$Logger.AddInfoRecord('Running Who Cleared Logs Report')
		$ExecutionTime = Start-TimeLog # Timer Start
		$TableEventLogClearedLogsOther = Get-EventLogClearedLogs -Events $Events -Type 'Other' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.IgnoreWords
		$script:TimeToGenerateReports.Reports.LogsClearedOther.Total = Stop-TimeLog -Time $ExecutionTime
		$Logger.AddInfoRecord('Ending Who Cleared Logs Report')
    }

	if ($ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -eq $true) {
		$ExecutionTime = Start-TimeLog # Timer St
		if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
			foreach ($LogName in $ReportDefinitions.ReportsAD.Servers.ForwardEventLog) {
				$Logger.AddInfoRecord("Running Event Log Size Report for $LogName log")
				$EventLogTable += Get-EventLogSize -Servers $ReportDefinitions.ReportsAD.Servers.ForwardServer  -LogName $LogName
				$Logger.AddInfoRecord("Ending Event Log Size Report for $LogName log")
			}
		}
		foreach ($LogName in $ReportDefinitions.ReportsAD.Custom.EventLogSize.Logs) {
			$Logger.AddInfoRecord("Running Event Log Size Report for $LogName log")
			$EventLogTable += Get-EventLogSize -Servers $Servers -LogName $LogName
			$Logger.AddInfoRecord("Ending Event Log Size Report for $LogName log")
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

    # Prepare email body
    $Logger.AddInfoRecord('Prepare email head and body')
	$EmailBody = Set-EmailHead -FormattingOptions $FormattingParameters
	$EmailBody += Set-EmailReportBranding -FormattingParameters $FormattingParameters
    $EmailBody += Set-EmailReportDetails -FormattingParameters $FormattingParameters -Dates $Dates -Warnings $Warnings

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
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Enabled -ReportTable $ComputerDeleted -ReportTableText 'Following computer deleted events happened'
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -ReportTable $LogonEvents -ReportTableText 'Following logon events happened'
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -ReportTable $LogonEventsKerberos -ReportTableText 'Following logon (kerberos) events happened'
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -ReportTable $GroupsEventsTable -ReportTableText 'The membership of those groups below has changed'
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -ReportTable $GroupCreateDeleteTable -ReportTableText 'Following group creation/deletion occured'
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -ReportTable $TableGroupPolicyChanges -ReportTableText 'Following GPOs were modified'
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -ReportTable $TableEventLogClearedLogs -ReportTableText 'Following logs clearing (security) actions occured '
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -ReportTable $TableEventLogClearedLogsOther -ReportTableText 'Following logs clearing (other) actions occured'
		$EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -ReportTable $RebootEventsTable -ReportTableText 'Following reboot related events happened'
	}
	$Reports = @()

    if ($ReportOptions.AsExcel) {
        $Logger.AddInfoRecord('Prepare XLSX files with Events')
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
	if ($ReportOptions.AsCSV) {
        $Logger.AddInfoRecord('Prepare CSV files with Events')
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
	$Reports = $Reports |  Where-Object { $_ } | Sort-Object -Unique

    $Logger.AddInfoRecord('Prepare Email replacements and formatting')
	# Do Cleanup of Emails
	$EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateDays**' -ReplaceWith $time.Elapsed.Days
	$EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateHours**' -ReplaceWith $time.Elapsed.Hours
	$EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateMinutes**' -ReplaceWith $time.Elapsed.Minutes
	$EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateSeconds**' -ReplaceWith $time.Elapsed.Seconds
	$EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateMilliseconds**' -ReplaceWith $time.Elapsed.Milliseconds
	$EmailBody = Set-EmailFormatting -Template $EmailBody -FormattingParameters $FormattingParameters -ConfigurationParameters $ReportOptions -Logger $Logger
	$Time.Stop()

    #$script:TimeToGenerateReports | ConvertTo-Json

    # Sending email - finalizing package
    if ($ReportOptions.SendMail) {
        $TemporarySubject = $EmailParameters.EmailSubject -replace "<<DateFrom>>", "$($Dates.DateFrom)" -replace "<<DateTo>>", "$($Dates.DateTo)"
        $Logger.AddInfoRecord('Sending email with reports')
        if ($FormattingParameters.CompanyBranding.Inline) {
            $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject -InlineAttachments @{logo = $FormattingParameters.CompanyBranding.Logo}
        } else {
            $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject
        }
        if ($SendMail.Status) {
            $Logger.AddInfoRecord('Email successfully sent')
        } else {
            $Logger.AddInfoRecord("Error sending message: $($SendMail.Error)")
        }
    }

    if ($ReportOptions.AsHTML) {
        $ReportHTMLPath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension 'html'
        $EmailBody | Out-File -Encoding Unicode -FilePath $ReportHTMLPath
        $Logger.AddInfoRecord("Saving report to file: $ReportHTMLPath")
        if ($ReportOptions.OpenAsFile) { Invoke-Item $ReportHTMLPath }
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
function Get-EventLogSize ($Servers, $LogName = "Security") {
    $results = @()
    foreach ($server in $Servers) {
        try {
            $result = get-WinEvent -ListLog $LogName -ComputerName $server | Select-Object MaximumSizeInBytes, FileSize, IsLogFul, LastAccessTime, LastWriteTime, OldestRecordNumber, RecordCount, LogName, LogType, LogIsolation, IsEnabled, LogMode
        } catch {
            Write-Color @script:WriteParameters "[-] ", "Event Log Error", "$($_.Exception)" -Color White, Red
            continue
        }
        $CurrentFileSize = Convert-Size -Value $($result.FileSize) -From Bytes -To GB -Precision 2 -Display
        $MaximumFilesize = Convert-Size -Value $($result.MaximumSizeInBytes) -From Bytes -To GB -Precision 2 -Display
        $EventOldest = (Get-WinEvent -MaxEvents 1 -LogName $result.LogName -Oldest -ComputerName $Server).TimeCreated
        $EventNewest = (Get-WinEvent -MaxEvents 1 -LogName $result.LogName -ComputerName $Server).TimeCreated
        Add-Member -InputObject $result -MemberType NoteProperty -Name "Server" -Value $server
        Add-Member -InputObject $result -MemberType NoteProperty -Name "CurrentFileSize" -Value $CurrentFileSize
        Add-Member -InputObject $result -MemberType NoteProperty -Name "MaximumFileSize" -Value $MaximumFilesize
        Add-Member -InputObject $result -MemberType NoteProperty -Name "EventOldest" -Value $EventOldest
        Add-Member -InputObject $result -MemberType NoteProperty -Name "EventNewest" -Value $EventNewest
        $results += $result
    }

    return $results | Select-Object Server, LogName, LogType, EventOldest, EventNewest, "CurrentFileSize", "MaximumFileSize", LogMode, IsEnabled
}

function Start-Report() {
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
    $LogonEvents = @()
    $LogonEventsKerberos = @()
    $RebootEventsTable = @()
    $TableGroupPolicyChanges = @()
    $TableEventLogClearedLogs = @()
    $ServersTable = @()
    $GroupCreateDeleteTable = @()
    $TableExecutionTimes = ''

    # Prepare email body
    $EmailBody = Set-EmailHead -FormattingParameters $FormattingParameters
    $EmailBody += Set-EmailReportBrading -FormattingParameters $FormattingParameters
    $EmailBody += Set-EmailReportDetails -FormattingParameters $FormattingParameters -Dates $Dates

    $Servers = Find-ServersAD -ReportDefinitions $ReportDefinitions
    $EventsToProcessSecurity = Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch 'Security'
    $EventsToProcessSystem = Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch 'System'

    $Events = @()
    $Events += Get-AllRequiredEvents -Servers $Servers -Dates $Dates -Events $EventsToProcessSecurity -LogName 'Security'
    $Events += Get-AllRequiredEvents -Servers $Servers -Dates $Dates -Events $EventsToProcessSystem -LogName 'System'

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
        $TableEventLogClearedLogs = Get-EventLogClearedLogs -Events $Events -Type 'Other' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.IgnoreWords
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
        $ServersTable = Get-DomainControllers -Servers $Servers
        $script:TimeToGenerateReports.Reports.ServersData.Total = Stop-TimeLog -Time $ExecutionTime
    }

    if ($ReportDefinitions.TimeToGenerate -eq $true) {
        $TableExecutionTimes = Set-TimeReports -HashTable $script:TimeToGenerateReports.Reports
    }

    # prepare body with HTML
    if ($ReportOptions.AsHTML) {
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.TimeToGenerate -ReportTable $TableExecutionTimes -ReportTableText 'Following report shows execution times' -Special
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportTable $ServersTable -ReportTableText 'Following servers have been processed for events'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportTable $EventLogTable -ReportTableText 'Following event log sizes were reported'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -ReportTable $UsersEventsTable -ReportTableText 'Following user changes happend'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -ReportTable $UsersEventsStatusesTable -ReportTableText 'Following user status happend'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -ReportTable $UsersLockoutsTable -ReportTableText 'Following user lockouts happend'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -ReportTable $LogonEvents -ReportTableText 'Following logon events happend'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -ReportTable $LogonEventsKerberos -ReportTableText 'Following logon (kerberos) events happend'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -ReportTable $GroupsEventsTable -ReportTableText 'The membership of those groups below has changed'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -ReportTable $GroupCreateDeleteTable -ReportTableText 'Following group creation/deletion occured'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -ReportTable $TableGroupPolicyChanges -ReportTableText 'Following GPOs were modified'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -ReportTable $TableEventLogClearedLogs -ReportTableText 'Following logs clearing (security) actions occured '
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -ReportTable $TableEventLogClearedLogsOther -ReportTableText 'Following logs clearing (other) actions occured'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -ReportTable $RebootEventsTable -ReportTableText 'Following reboot related events happened'
    }
    $Reports = @()
    If ($ReportOptions.AsExcel) {
        $ReportFilePathXLSX = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension "xlsx"
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Processed Servers" -ReportTable $ServersTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Event log sizes" -ReportTable $EventLogTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "User Changes" -ReportTable $UsersEventsTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "User Status Changes" -ReportTable $UsersEventsStatusesTable
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "User Lockouts" -ReportTable $UsersLockoutsTable
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
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportServers" -ReportTable $ServersTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportEventLogSize" -ReportTable $EventLogTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserEvents" -ReportTable $UsersEventsTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserStatuses" -ReportTable $UsersEventsStatusesTable
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserLockouts" -ReportTable $UsersLockoutsTable
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
    $Time.Stop()

    #$script:TimeToGenerateReports | ConvertTo-Json

    # Sending email - finalizing package
    if ($ReportOptions.SendMail -eq $true) {
        $TemporarySubject = $EmailParameters.EmailSubject -replace "<<DateFrom>>", "$($Dates.DateFrom)" -replace "<<DateTo>>", "$($Dates.DateTo)"
        Write-Color @script:WriteParameters "[i] Sending email with reports..." -Color White, Green -NoNewLine
        $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject
        if ($SendMail.Status -eq $True) {
            Write-Color "Success!" -Color Green
        } else {
            Write-Color "Not working!" -Color Red
            Write-Color @script:WriteParameters "[i] Error: ", "$($SendMail.Error)" -Color White, Red
        }
    } else {
        Write-Color @script:WriteParameters "[i] Skipping sending email with reports...", "as per configuration!" -Color White, Green
    }
    if ($ReportOptions.OpenAsFile -eq $true) {
        # $EmailBody | Out-File -FilePath
    }

    Remove-ReportsFiles -KeepReports $ReportOptions.KeepReports -AsExcel $ReportOptions.AsExcel -AsCSV $ReportOptions.AsCSV -ReportFiles $Reports
}

function Set-TimeReports ($HashTable) {
    # Get all report Names
    $Reports = @()
    foreach ($reportName in $($HashTable.GetEnumerator().Name)) {
        $Reports += $reportName
    }

    # Get Highest Count of servers
    $Count = 0
    foreach ($reportName in $reports) {
        if ($($HashTable[$reportName]).Count -ge $Count) {
            $Count = $($HashTable[$reportName]).Count
        }
    }
    $Count = $Count - 1 # Removes Total from Server Count

    $htmlStart = @"
    <table border="0" cellpadding="3" style="font-size:8pt;font-family:Segoe UI,Arial,sans-serif">
        <tr bgcolor="#009900">
            <th colspan="1">
                <font color="#ffffff">Report Names</font>
            </th>
            <th colspan="1">
                <font color="#ffffff">Total</font>
            </th>
        </tr>
"@

    foreach ($reportName in $reports) {
        $htmlStart += '<tr align="left" bgcolor="#dddddd">'

        $htmlStart += '<td>' + $reportName + '</td>'

        foreach ($ElapsedTime in $($HashTable[$reportName].GetEnumerator())) {

            # Write-Color -Text $($ElapsedTime.Value) -Color Red
            $htmlStart += '<td>' + $($ElapsedTime.Value) + '</td>'
        }
        $htmlStart += '</tr>'
    }

    $htmlStart += '</table>'


    return $htmlStart
}
function Get-DomainControllers($Servers) {
    $DomainControllers = @()
    try {
        $DomainControllers = Get-ADDomainController -Filter * -ErrorAction 'Stop' | Select-Object Name , HostName, Ipv4Address, IsGlobalCatalog, IsReadOnly, OperatingSystem, Site, Enabled #, Supported, Reporting #,
    } catch {
        if ($_.Exception -match "Unable to find a default server with Active Directory Web Services running.") {
            Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
        }
        Write-Color @script:WriteParameters "[i] Error: ", "$($_.Exception.Message)" -Color White, Red
    }
    foreach ($dc in $DomainControllers) {
        Add-Member -InputObject $dc -MemberType NoteProperty -Name "Supported" -Value ""
        Add-Member -InputObject $dc -MemberType NoteProperty -Name "Reporting" -Value ""
        if ($dc.OperatingSystem -like "*2003*" -or $dc.OperatingSystem -like "*2000*") {
            #Add-Member -InputObject $server -MemberType NoteProperty -Name "Supported" -Value "No"
            $dc.Supported = "No"
        } else {
            #Add-Member -InputObject $server -MemberType NoteProperty -Name "Supported" -Value "Yes"
            $dc.Supported = "Yes"
        }
        foreach ($s in $servers) {
            if ($s -eq $dc.Hostname -or $s -eq $dc.Name) {
                $dc.Reporting = $true
            }
        }
    }
    return $DomainControllers
}

function Get-Servers($ReportOptions) {
    $Servers = @()
    if ($ReportOptions.OnlyPrimaryDC -eq $true) {
        $ServerOptions = @{
            Server      = (get-addomain).pdcemulator;
            ErrorAction = "Stop"
        }
    } else {
        $ServerOptions = @{
            Filter      = "*";
            ErrorAction = "Stop"
        }
    }
    try {
        $Servers = Get-ADDomainController @ServerOptions | Select-Object Name, HostName, Ipv4Address, IsGlobalCatalog, IsReadOnly, OperatingSystem, Site, Enabled, Supported #, EventsFound
    } catch {
        if ($_.Exception -match "Unable to find a default server with Active Directory Web Services running.") {
            Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
        }
        Write-Color @script:WriteParameters "[i] Error: ", "$($_.Exception.Message)" -Color White, Red
    }
    return $Servers
}


function Find-ServersAD ($ReportDefinitions) {
    if ($ReportDefinitions.ReportsAD.Servers.Automatic -eq $true) {
        if ($ReportDefinitions.ReportsAD.Servers.OnlyPDC -eq $true) {
            $ServerOptions = @{
                Server = (get-addomain).pdcemulator; ErrorAction = "Stop"
            }
        } else {
            $ServerOptions = @{
                Filter = "*"; ErrorAction = "Stop"
            }
        }
        try {
            $Servers = Get-ADDomainController @ServerOptions | Select-Object Name , HostName, Ipv4Address, IsGlobalCatalog, IsReadOnly, OperatingSystem, Site, Enabled, Supported #, EventsFound
            $Servers = $Servers | Where-Object { $_.OperatingSystem -notlike "*2003*" -and $_.OperatingSystem -notlike "*2000*" }
            $Servers = $Servers.Hostname
            return $Servers
        } catch {
            if ($_.Exception -match "Unable to find a default server with Active Directory Web Services running.") {
                Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
            }
            Write-Color @script:WriteParameters "[i] Error: ", "$($_.Exception.Message)" -Color White, Red
            Exit
        }
    } else {
        if ($ReportDefinitions.ReportsAD.Servers.DC -eq '') {
            Write-Color @script:WriteParameters "[i] Error: ", "Parameter ", 'ReportDefinitions.ReportsAD.Servers.DC', ' is empty. Please choose ', 'Automatic', ' or fill in this field.' -Color White, White, Yellow, White, Yellow, White
            Exit
        } else {
            return $ReportDefinitions.ReportsAD.Servers.DC
        }
    }
}

function Find-AllEvents($ReportDefinitions, $LogNameSearch) {
    $EventsToProcess = @()
    foreach ($report in $ReportDefinitions.ReportsAD.EventBased.GetEnumerator()) {
        $ReportName = $report.Name
        $Enabled = $ReportDefinitions.ReportsAD.EventBased.$ReportName.Enabled
        $LogName = $ReportDefinitions.ReportsAD.EventBased.$ReportName.LogName
        $Events = $ReportDefinitions.ReportsAD.EventBased.$ReportName.Events
        #$IgnoreWords = $ReportDefinitions.ReportsAD.EventBased.$ReportName.IgnoreWords

        if ($Enabled -eq $true) {
            if ($LogNameSearch -eq $LogName) {
                $EventsToProcess += $Events
            }
        }
    }
    return $EventsToProcess
}

function Get-AllRequiredEvents ($Servers, $Dates, $Events, $LogName) {
    $Count = Get-Count $Events
    if ($Count -ne 0) {
        Get-Events -Server $Servers -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $Events -LogName $LogName -Verbose
        #Get-Events -Server $Servers -EventID $Events -LogName $LogName -Verbose
    }
}

function Get-Count($Object) {
    return $($Object | Measure-Object).Count
}

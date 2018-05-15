<#
    .SYNOPSIS
    This PowerShell script can generate report according to your defined parameters and monitor for changes that happen on users and groups in Active Directory.
    .DESCRIPTION
    This PowerShell script can generate report according to your defined parameters and monitor for changes that happen on users and groups in Active Directory.

    It can tell you:
    - When and who changed the group membership of any group within your Active Directory Domain
    - When and who changed the user data including Password, UserPrincipalName, SamAccountName, and so on…
    - When and who changed passwords
    - When and who locked out account and where did it happen
    .NOTES
    Version:        0.91
    Author:         Przemyslaw Klys <przemyslaw.klys at evotec.pl>
    Creation Date:  23.03.2018
    Modifcation Date: 12.05.2018

    TODO:
    - DirectoryPattern                = $true # adds to reports path Hourly \ Monthly \ Quarterly \ Custom ("C:\Support\Reports\Hourly")
    - Fixes for reports

    Newest version of the script is always available at: https://evotec.xyz/hub/scripts/get-eventslibrary-ps1/

    Additonal notes for self for using it later
    Users https://www.ultimatewindowssecurity.com/securitylog/book/page.aspx?spid=chapter8#UAM
    4720: A user account was created                                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4720
    4722: A user account was enabled                                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4722
    4725: A user account was disabled                                   https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4725
    4726: A user account was deleted                                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4726
    4738: A user account was changed                                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4738
    4740: A user account was locked out.                                https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4740
    4767: A user account was unlocked.                                  https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4767
    4781: The name of an account was changed                            https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4781
    4723: An attempt was made to change an account's password           https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4723
    4724: An attempt was made to reset an accounts password             https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4724

    .EXAMPLE
    Examples of usage can be found at https://evotec.xyz/monitoring-active-directory-changes-on-users-and-groups-with-powershell
#>
Set-StrictMode -Version Latest

# Default value / overwritten if set in config
$script:WriteParameters = @{
    ShowTime   = $true
    LogFile    = ""
    TimeFormat = "yyyy-MM-dd HH:mm:ss"
}
$script:TimeToGenerateReports = [ordered]@{
    Reports = @{
        IncludeDomainControllers        = @{
            Total = $null
        }
        IncludeGroupEvents              = @{
            Total = $null
        }
        IncludeGroupCreateDelete        = @{
            Total = $null
        }
        IncludeUserEvents               = @{
            Total = $null
        }
        IncludeUserStatuses             = @{
            Total = $null
        }
        IncludeUserLockouts             = @{
            Total = $null
        }
        IncludeDomainControllersReboots = @{
            Total = $null
        }
        IncludeLogonEvents              = @{
            Total = $null
        }
        IncludeGroupPolicyChanges       = @{
            Total = $null
        }
        IncludeClearedLogs              = @{
            Total = $null
        }
        IncludeEventLogSize             = @{
            Total = $null
        }
    }
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
            <th colspan="$Count">
                <font color="#ffffff">Servers</font>
            </th>
        </tr>
"@

    $htmlStart += '<tr bgcolor="#00CC00">'
    $htmlStart += '<th></th>'
    $htmlStart += '<th></th>'

    #$HashTable.GetEnumerator()
    foreach ($reportName in $reports) {
        if ($($HashTable[$reportName]).Count -eq $($Count + 1)) {
            foreach ($server in $($HashTable[$reportName].GetEnumerator().Name)) {
                if ($server -ne 'Total') {
                    $htmlStart += '<th>' + $server + '</th>'
                }
            }
            break;
        }
    }
    $htmlStart += '</tr>'

    #
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
    foreach ($server in $servers) {
        $ExecTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
        if ($server.OperatingSystem -like "*2003*" -or $server.OperatingSystem -like "*2000*") {
            #Add-Member -InputObject $server -MemberType NoteProperty -Name "Supported" -Value "No"
            $server.Supported = "No"
        } else {
            #Add-Member -InputObject $server -MemberType NoteProperty -Name "Supported" -Value "Yes"
            $server.Supported = "Yes"
        }

        $TimeReport = "$($ExecTime.Elapsed.Days) days, $($ExecTime.Elapsed.Hours) hours, $($ExecTime.Elapsed.Minutes) minutes, $($ExecTime.Elapsed.Seconds) seconds, $($ExecTime.Elapsed.Milliseconds) milliseconds"
        $script:TimeToGenerateReports.Reports.IncludeDomainControllers.$($server.HostName) = $TimeReport
        $ExecTime.Stop()
    }
    $ServersTable = $Servers
    return $ServersTable
}

function Start-Report([hashtable] $Dates, [hashtable] $EmailParameters, [hashtable] $ReportOptions, [hashtable] $FormattingOptions, $Servers) {
    $time = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
    # Declare variables
    $EventLogTable = @()
    $GroupsEventsTable = @()
    $UsersEventsTable = @()
    $UsersEventsStatusesTable = @()
    $UsersLockoutsTable = @()
    $LogonEvents = @()
    $RebootEventsTable = @()
    $TableGroupPolicyChanges = @()
    $TableEventLogClearedLogs = @()
    $ServersTable = @()
    $GroupCreateDeleteTable = @()
    $TableExecutionTimes = ''

    # Prepare email body
    $EmailBody = Set-EmailHead  -FormattingOptions $FormattingOptions
    $EmailBody += Set-EmailReportBrading -FormattingOptions $FormattingOptions
    $EmailBody += Set-EmailReportDetails -FormattingOptions $FormattingOptions -Dates $Dates

    # Load all events if required
    if ($ReportOptions.IncludeDomainControllers -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start

        $ServersTable = Get-DomainControllers -Servers $Servers

        $script:TimeToGenerateReports.Reports.IncludeDomainControllers.Total = Stop-TimeLog -Time $ExecutionTime
    }
    $Servers = $Servers | Where-Object { $_.OperatingSystem -notlike "*2003*" -and $_.OperatingSystem -notlike "*2000*" }
    $Servers = $Servers.Hostname

    If ($ReportOptions.IncludeClearedLogs -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogs = Get-EventLogClearedLogs -Servers $Servers -Dates $Dates
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.IncludeClearedLogs.Total = Stop-TimeLog -Time $ExecutionTime
    }
    If ($ReportOptions.IncludeEventLogSize.Use -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer St
        foreach ($LogName in $ReportOptions.IncludeEventLogSize.Logs) {
            Write-Color @script:WriteParameters "[i] Running ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
            $EventLogTable = Get-EventLogSize -Servers $Servers -LogName $LogName
            Write-Color @script:WriteParameters "[i] Ending ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
        }
        if ($ReportOptions.IncludeEventLogSize.SortBy -ne "") { $EventLogTable = $EventLogTable | Sort-Object $ReportOptions.IncludeEventLogSize.SortBy }
        $script:TimeToGenerateReports.Reports.IncludeEventLogSize.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeGroupEvents -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer St
        $GroupsEventsTable = Get-GroupMembershipChanges -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeGroupEvents.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeUserEvents -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsTable = Get-UserChanges -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeUserEvents.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeUserStatuses -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsStatusesTable = Get-UserStatuses -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeUserStatuses.Total = Stop-TimeLog -Time $ExecutionTime
    }
    If ($ReportOptions.IncludeUserLockouts -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer
        $UsersLockoutsTable = Get-UserLockouts -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeUserLockouts.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeLogonEvents -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer
        $LogonEvents = Get-LogonEvents -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeLogonEvents.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeGroupCreateDelete -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer
        $GroupCreateDeleteTable = Get-GroupCreateDelete -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeGroupCreateDelete.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeDomainControllersReboots -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer
        $RebootEventsTable = Get-RebootEvents -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeDomainControllersReboots.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeGroupPolicyChanges -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer
        $TableGroupPolicyChanges = Get-GroupPolicyChanges -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeGroupPolicyChanges.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeTimeToGenerate -eq $true) {
        $TableExecutionTimes = Set-TimeReports -HashTable $script:TimeToGenerateReports.Reports
    }
    # prepare body with HTML
    if ($ReportOptions.AsHTML) {
        if ($ReportOptions.IncludeTimeToGenerate -eq $true) {
            #$EmailBody += Set-EmailBody -TableData $TableExecutionTimes -TableWelcomeMessage "Following report shows execution times"
            $EmailBody += Set-EmailBodyPreparedTable -TableData $TableExecutionTimes -TableWelcomeMessage "Following report shows execution times"
        }
        if ($ReportOptions.IncludeDomainControllers -eq $true) {
            $EmailBody += Set-Emailbody -TableData $ServersTable -TableWelcomeMessage "Following servers have been processed for events"
        }
        If ($ReportOptions.IncludeClearedLogs -eq $true) {
            $EmailBody += Set-Emailbody -TableData $TableEventLogClearedLogs -TableWelcomeMessage "Following events regarding cleaning logs have occured"
        }
        If ($ReportOptions.IncludeEventLogSize.Use -eq $true) {
            $EmailBody += Set-EmailBody -TableData $EventLogTable -TableWelcomeMessage "Following event log sizes were reported"
        }
        if ($ReportOptions.IncludeGroupEvents -eq $true) {
            $EmailBody += Set-EmailBody -TableData $GroupsEventsTable -TableWelcomeMessage "The membership of those groups below has changed"
        }
        if ($ReportOptions.IncludeUserEvents -eq $true) {
            $EmailBody += Set-EmailBody -TableData $UsersEventsTable -TableWelcomeMessage "Following user changes happend"
        }
        if ($ReportOptions.IncludeUserStatuses -eq $true) {
            $EmailBody += Set-EmailBody -TableData $UsersEventsStatusesTable -TableWelcomeMessage "Following user status happend"
        }
        If ($ReportOptions.IncludeUserLockouts -eq $true) {
            $EmailBody += Set-EmailBody -TableData $UsersLockoutsTable -TableWelcomeMessage "Following user lockouts happend"
        }
        if ($ReportOptions.IncludeLogonEvents -eq $true) {
            $EmailBody += Set-EmailBody -TableData $LogonEvents -TableWelcomeMessage "Following logon events happend"
        }
        if ($ReportOptions.IncludeGroupCreateDelete -eq $true) {
            $EmailBody += Set-EmailBody -TableData $GroupCreateDeleteTable -TableWelcomeMessage "Following group creation/deletion occured"
        }
        if ($ReportOptions.IncludeDomainControllersReboots -eq $true) {
            $EmailBody += Set-EmailBody -TableData $RebootEventsTable -TableWelcomeMessage "Following reboot related events happened"
        }
        if ($ReportOptions.IncludeGroupPolicyChanges -eq $true) {
            $EmailBody += Set-EmailBody -TableData $TableGroupPolicyChanges -TableWelcomeMessage "Following group policy changes happend"
        }
    }
    $Reports = @()
    If ($ReportOptions.AsExcel) {
        $ReportFilePathXLSX = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension "xlsx"
        Export-ReportToXLSX -Report $ReportOptions.IncludeDomainControllers -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Processed Servers" -ReportTable $ServersTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeClearedLogs -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Clear Log Events" -ReportTable $TableEventLogClearedLogs
        Export-ReportToXLSX -Report $ReportOptions.IncludeEventLogSize.Use -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Event log sizes" -ReportTable $EventLogTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeGroupEvents -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Membership Changes"  -ReportTable $GroupsEventsTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeGroupCreateDelete -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Creation Deletion Changes"  -ReportTable $GroupCreateDeleteTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeUserEvents -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "User Changes" -ReportTable $UsersEventsTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeUserStatuses -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "User Status Changes" -ReportTable $UsersEventsStatusesTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeUserLockouts -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "User Lockouts" -ReportTable $UsersLockoutsTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeLogonEvents -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "User Logon Events" -ReportTable $LogonEvents
        Export-ReportToXLSX -Report $ReportOptions.IncludeDomainControllersReboots -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Troubleshooting Reboots" -ReportTable $RebootEventsTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeGroupPolicyChanges -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Policy Changes" -ReportTable $TableGroupPolicyChanges
        $Reports += $ReportFilePathXLSX
    }
    If ($ReportOptions.AsCSV) {
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeDomainControllers -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportServers" -ReportTable $ServersTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeClearedLogs -ReportOptions $ReportOptions -Extension "csv" -ReportName "IncludeClearedLogs" -ReportTable $TableEventLogClearedLogs
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeEventLogSize.Use -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportEventLogSize" -ReportTable $EventLogTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeGroupEvents -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupEvents" -ReportTable $GroupsEventsTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeGroupCreateDelete -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupCreateDeleteEvents" -ReportTable $GroupCreateDeleteTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeUserEvents -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserEvents" -ReportTable $UsersEventsTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeUserStatuses -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserStatuses" -ReportTable $UsersEventsStatusesTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeUserLockouts -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserLockouts" -ReportTable $UsersLockoutsTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeLogonEvents -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserLogons" -ReportTable $LogonEvents
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeDomainControllersReboots -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportReboots" -ReportTable $RebootEventsTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeGroupPolicyChanges -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupPolicyChanges" -ReportTable $TableGroupPolicyChanges
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

    Remove-ReportsFiles -KeepReports $ReportOptions.KeepReports -AsExcel $ReportOptions.AsExcel -AsCSV $ReportOptions.AsCSV -ReportFiles $Reports
}

function Get-Servers($ReportOptions) {
    $Servers = @()
    if ($ReportOptions.OnlyPrimaryDC -eq $true) { $ServerOptions = @{ Server = (get-addomain).pdcemulator; ErrorAction = "Stop" }
    } else { $ServerOptions = @{ Filter = "*"; ErrorAction = "Stop" }
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
function Start-ADReporting ($EmailParameters, $ReportOptions, $FormattingOptions, $ScriptParameters) {

    $Test1 = Test-Key -ConfigurationTable $ScriptParameters -ConfigurationSection "" -ConfigurationKey "ShowTime" -DisplayProgress $false
    $Test2 = Test-Key -ConfigurationTable $ScriptParameters -ConfigurationSection "" -ConfigurationKey "LogFile" -DisplayProgress $false
    $Test3 = Test-Key -ConfigurationTable $ScriptParameters -ConfigurationSection "" -ConfigurationKey "TimeFormat" -DisplayProgress $false
    if ($Test1 -and $Test2 -and $Test3) { $script:WriteParameters = $ScriptParameters }
    Test-Prerequisite $EmailParameters $ReportOptions $FormattingOptions
    if ($ReportOptions.JustTestPrerequisite -ne $null -and $ReportOptions.JustTestPrerequisite -eq $true) {
        Exit
    }
    $Servers = Get-Servers $ReportOptions
    # Report Per Hour
    if ($ReportOptions.ReportPastHour -eq $true) {
        $DatesPastHour = Find-DatesPastHour
        if ($DatesPastHour -ne $null) {
            Start-Report -Dates $DatesPastHour $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentHour -eq $true) {
        $DatesCurrentHour = Find-DatesCurrentHour
        if ($DatesCurrentHour -ne $null) {
            Start-Report -Dates $DatesCurrentHour $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    # Report Per Day
    if ($ReportOptions.ReportPastDay -eq $true) {
        $DatesDayPrevious = Find-DatesDayPrevious
        if ($DatesDayPrevious -ne $null) {
            Start-Report -Dates $DatesDayPrevious $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentDay -eq $true) {
        $DatesDayToday = Find-DatesDayToday
        if ($DatesDayToday -ne $null) {
            Start-Report -Dates $DatesDayToday $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    # Report Per Week
    if ($ReportOptions.ReportOnDay.Use -eq $true) {
        foreach ($Day in $ReportOptions.ReportOnDay.Days) {
            $DatesReportOnDay = Find-DatesPastWeek $Day
            if ($DatesReportOnDay -ne $null) {
                Start-Report -Dates $DatesReportOnDay $EmailParameters $ReportOptions $FormattingOptions $Servers
            }
        }
    }
    # Report Per Month
    if ($ReportOptions.ReportPastMonth.Use -eq $true -or $ReportOptions.ReportPastMonth.Force -eq $true) {
        $DatesMonthPrevious = Find-DatesMonthPast -Force $ReportOptions.ReportPastMonth.Force     # Find-DatesMonthPast runs only on 1st of the month unless -Force is used
        if ($DatesMonthPrevious -ne $null) {
            Start-Report -Dates $DatesMonthPrevious -EmailParameters $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentMonth -eq $true) {
        $DatesMonthCurrent = Find-DatesMonthCurrent
        if ($DatesMonthCurrent -ne $null) {
            Start-Report -Dates $DatesMonthCurrent $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    # Report Per Quarter
    if ($ReportOptions.ReportPastQuarter.Use -eq $true -or $ReportOptions.ReportPastQuarter.Force -eq $true) {
        $DatesQuarterLast = Find-DatesQuarterLast -Force $ReportOptions.ReportPastQuarter.Force  # Find-DatesMonthPast runs only on 1st of the quarter unless -Force is used
        if ($DatesQuarterLast -ne $null) {
            Start-Report -Dates $DatesQuarterLast $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentQuarter -eq $true) {
        $DatesQuarterCurrent = Find-DatesQuarterCurrent
        if ($DatesQuarterCurrent -ne $null) {
            Start-Report -Dates $DatesQuarterCurrent $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    # Report Custom
    if ($ReportOptions.ReportCurrentDayMinusDayX.Use -eq $true) {
        $DatesCurrentDayMinusDayX = Find-DatesCurrentDayMinusDayX $ReportOptions.ReportCurrentDayMinusDayX.Days
        if ($DatesCurrentDayMinusDayX -ne $null) {
            Start-Report -Dates $DatesCurrentDayMinusDayX $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentDayMinuxDaysX.Use -eq $true) {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX $ReportOptions.ReportCurrentDayMinuxDaysX.Days
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            Start-Report -Dates $DatesCurrentDayMinusDaysX $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCustomDate.Use -eq $true) {
        $DatesCustom = @{
            DateFrom = $ReportOptions.ReportCustomDate.DateFrom
            DateTo   = $ReportOptions.ReportCustomDate.DateTo
        }
        if ($DatesCustom -ne $null) {
            Start-Report -Dates $DatesCustom $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }

}

#xport-ModuleMember -function 'Start-ADReporting'
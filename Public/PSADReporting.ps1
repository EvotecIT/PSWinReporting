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
    Reports = [ordered] @{
        UserChanges            = @{
            Total = $null
        }
        UserStatus             = @{
            Total = $null
        }
        UserLockouts           = @{
            Total = $null
        }
        UserLogon              = @{
            Total = $null
        }
        GroupMembershipChanges = @{
            Total = $null
        }
        GroupCreateDelete      = @{
            Total = $null
        }
        GroupPolicyChanges     = @{
            Total = $null
        }
        LogsClearedSecurity    = @{
            Total = $null
        }
        LogsClearedOther       = @{
            Total = $null
        }
        EventsReboots          = @{
            Total = $null
        }
        EventLogSize           = @{
            Total = $null
        }
        ServersData            = @{
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
    Add-Member -InputObject $DomainControllers -MemberType NoteProperty -Name "Supported" -Value ""
    Add-Member -InputObject $DomainControllers -MemberType NoteProperty -Name "Reporting" -Value ""
    foreach ($dc in $DomainControllers) {

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
        return $DomainControllers
    }
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
        $UsersEventsTable = Get-UserChanges -Events $Events
        $script:TimeToGenerateReports.Reports.UserChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsStatusesTable = Get-UserStatuses -Events $Events
        $script:TimeToGenerateReports.Reports.UserStatus.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersLockoutsTable = Get-UserLockouts -Events $Events
        $script:TimeToGenerateReports.Reports.UserLockouts.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $LogonEvents = Get-LogonEvents -Events $Events
        $script:TimeToGenerateReports.Reports.UserLogon.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    }
    ### USER EVENTS END ###

    if ($ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report" -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer St
        $GroupsEventsTable = Get-GroupMembershipChanges -Events $Events
        $script:TimeToGenerateReports.Reports.GroupMembershipChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $GroupCreateDeleteTable = Get-GroupCreateDelete -Events $Events
        $script:TimeToGenerateReports.Reports.GroupCreateDelete.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer
        $RebootEventsTable = Get-RebootEvents -Events $Events
        $script:TimeToGenerateReports.Reports.EventsReboots.Total = Stop-TimeLog -Time $ExecutionTime
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $TableGroupPolicyChanges = Get-GroupPolicyChanges -Events $Events
        $script:TimeToGenerateReports.Reports.GroupPolicyChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogs = Get-EventLogClearedLogs -Events $Events -Type 'Other'
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.LogsClearedSecurity.Total = Stop-TimeLog -Time $ExecutionTime
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogsOther = Get-EventLogClearedLogs -Events $Events -Type 'Other'
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.LogsClearedOther.Total = Stop-TimeLog -Time $ExecutionTime
    }
    If ($ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer St
        foreach ($LogName in $ReportDefinitions.ReportsAD.Custom.EventLogSize.Logs) {
            Write-Color @script:WriteParameters "[i] Running ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
            $EventLogTable = Get-EventLogSize -Servers $Servers -LogName $LogName
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

    Remove-ReportsFiles -KeepReports $ReportOptions.KeepReports -AsExcel $ReportOptions.AsExcel -AsCSV $ReportOptions.AsCSV -ReportFiles $Reports
}
function Start-ADReporting () {
    param (
        [hashtable]$EmailParameters,
        [hashtable]$FormattingParameters,
        [hashtable]$ReportOptions,
        [hashtable]$ReportTimes,
        [hashtable]$ReportDefinitions
    )
    Set-DisplayParameters -ReportOptions $ReportOptions

    #Test-Prerequisite $EmailParameters $FormattingParameters $ReportOptions $ReportTimes $ReportDefinitions
    if ($ReportOptions.JustTestPrerequisite -ne $null -and $ReportOptions.JustTestPrerequisite -eq $true) {
        Exit
    }

    # Report Per Hour
    if ($ReportTimes.PastHour -eq $true) {
        $DatesPastHour = Find-DatesPastHour
        if ($DatesPastHour -ne $null) {
            Start-Report -Dates $DatesPastHour -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    if ($ReportTimes.CurrentHour -eq $true) {
        $DatesCurrentHour = Find-DatesCurrentHour
        if ($DatesCurrentHour -ne $null) {
            Start-Report -Dates $DatesCurrentHour -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    # Report Per Day
    if ($ReportTimes.PastDay -eq $true) {
        $DatesDayPrevious = Find-DatesDayPrevious
        if ($DatesDayPrevious -ne $null) {
            Start-Report -Dates $DatesDayPrevious -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    if ($ReportTimes.CurrentDay -eq $true) {
        $DatesDayToday = Find-DatesDayToday
        if ($DatesDayToday -ne $null) {
            Start-Report -Dates $DatesDayToday -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    # Report Per Week
    if ($ReportTimes.OnDay.Enabled -eq $true) {
        foreach ($Day in $ReportTimes.OnDay.Days) {
            $DatesReportOnDay = Find-DatesPastWeek $Day
            if ($DatesReportOnDay -ne $null) {
                Start-Report -Dates $DatesReportOnDay -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
            }
        }
    }
    # Report Per Month
    if ($ReportTimes.PastMonth.Enabled -eq $true -or $ReportTimes.PastMonth.Force -eq $true) {
        $DatesMonthPrevious = Find-DatesMonthPast -Force $ReportTimes.PastMonth.Force     # Find-DatesMonthPast runs only on 1st of the month unless -Force is used
        if ($DatesMonthPrevious -ne $null) {
            Start-Report -Dates $DatesMonthPrevious -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    if ($ReportTimes.CurrentMonth -eq $true) {
        $DatesMonthCurrent = Find-DatesMonthCurrent
        if ($DatesMonthCurrent -ne $null) {
            Start-Report -Dates $DatesMonthCurrent -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    # Report Per Quarter
    if ($ReportTimes.PastQuarter.Enabled -eq $true -or $ReportTimes.PastQuarter.Force -eq $true) {
        $DatesQuarterLast = Find-DatesQuarterLast -Force $ReportTimes.PastQuarter.Force  # Find-DatesMonthPast runs only on 1st of the quarter unless -Force is used
        if ($DatesQuarterLast -ne $null) {
            Start-Report -Dates $DatesQuarterLast -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    if ($ReportTimes.CurrentQuarter -eq $true) {
        $DatesQuarterCurrent = Find-DatesQuarterCurrent
        if ($DatesQuarterCurrent -ne $null) {
            Start-Report -Dates $DatesQuarterCurrent -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    # Report Custom
    if ($ReportTimes.CurrentDayMinusDayX.Enabled -eq $true) {
        $DatesCurrentDayMinusDayX = Find-DatesCurrentDayMinusDayX $ReportTimes.CurrentDayMinusDayX.Days
        if ($DatesCurrentDayMinusDayX -ne $null) {
            Start-Report -Dates $DatesCurrentDayMinusDayX -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    if ($ReportTimes.CurrentDayMinuxDaysX.Enabled -eq $true) {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX $ReportTimes.CurrentDayMinuxDaysX.Days
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            Start-Report -Dates $DatesCurrentDayMinusDaysX -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }
    if ($ReportTimes.CustomDate.Enabled -eq $true) {
        $DatesCustom = @{
            DateFrom = $ReportTimes.CustomDate.DateFrom
            DateTo   = $ReportTimes.CustomDate.DateTo
        }
        if ($DatesCustom -ne $null) {
            Start-Report -Dates $DatesCustom -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
        }
    }

}
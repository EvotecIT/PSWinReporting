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
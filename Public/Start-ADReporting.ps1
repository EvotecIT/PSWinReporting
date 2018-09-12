function Start-ADReporting () {
    param (
        [hashtable]$EmailParameters,
        [hashtable]$FormattingParameters,
        [hashtable]$ReportOptions,
        [hashtable]$ReportTimes,
        [hashtable]$ReportDefinitions
    )
    Set-DisplayParameters -ReportOptions $ReportOptions

    Test-Prerequisite $EmailParameters $FormattingParameters $ReportOptions $ReportTimes $ReportDefinitions
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
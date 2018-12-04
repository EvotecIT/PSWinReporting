function Get-ChoosenDates {
    param(
        $ReportTimes
    )
    $Dates = @()

    # Report Per Hour
    if ($ReportTimes.PastHour) {
        $DatesPastHour = Find-DatesPastHour
        if ($DatesPastHour -ne $null) {
            $Dates += $DatesPastHour
        }
    }
    if ($ReportTimes.CurrentHour) {
        $DatesCurrentHour = Find-DatesCurrentHour
        if ($DatesCurrentHour -ne $null) {
            $Dates += $DatesCurrentHour
        }
    }
    # Report Per Day
    if ($ReportTimes.PastDay) {
        $DatesDayPrevious = Find-DatesDayPrevious
        if ($DatesDayPrevious -ne $null) {
            $Dates += $DatesDayPrevious
        }
    }
    if ($ReportTimes.CurrentDay) {
        $DatesDayToday = Find-DatesDayToday
        if ($DatesDayToday -ne $null) {
            $Dates += $DatesDayToday
        }
    }
    # Report Per Week
    if ($ReportTimes.OnDay.Enabled) {
        foreach ($Day in $ReportTimes.OnDay.Days) {
            $DatesReportOnDay = Find-DatesPastWeek $Day
            if ($DatesReportOnDay -ne $null) {
                $Dates += $DatesReportOnDay
            }
        }
    }
    # Report Per Month
    if ($ReportTimes.PastMonth.Enabled) {
        # Find-DatesMonthPast runs only on 1st of the month unless -Force is used
        $DatesMonthPrevious = Find-DatesMonthPast -Force $ReportTimes.PastMonth.Force
        if ($DatesMonthPrevious -ne $null) {
            $Dates += $DatesMonthPrevious
        }
    }
    if ($ReportTimes.CurrentMonth) {
        $DatesMonthCurrent = Find-DatesMonthCurrent
        if ($DatesMonthCurrent -ne $null) {
            $Dates += $DatesMonthCurrent
        }
    }
    # Report Per Quarter
    if ($ReportTimes.PastQuarter.Enabled) {
        # Find-DatesMonthPast runs only on 1st of the quarter unless -Force is used
        $DatesQuarterLast = Find-DatesQuarterLast -Force $ReportTimes.PastQuarter.Force
        if ($DatesQuarterLast -ne $null) {
            $Dates += $DatesQuarterLast
        }
    }
    if ($ReportTimes.CurrentQuarter) {
        $DatesQuarterCurrent = Find-DatesQuarterCurrent
        if ($DatesQuarterCurrent -ne $null) {
            $Dates += $DatesQuarterCurrent
        }
    }
    # Report Custom
    if ($ReportTimes.CurrentDayMinusDayX.Enabled) {
        $DatesCurrentDayMinusDayX = Find-DatesCurrentDayMinusDayX $ReportTimes.CurrentDayMinusDayX.Days
        if ($DatesCurrentDayMinusDayX -ne $null) {
            $Dates += $DatesCurrentDayMinusDayX
        }
    }
    if ($ReportTimes.CurrentDayMinuxDaysX.Enabled) {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX $ReportTimes.CurrentDayMinuxDaysX.Days
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            $Dates += $DatesCurrentDayMinusDaysX
        }
    }
    if ($ReportTimes.CustomDate.Enabled) {
        $DatesCustom = @{
            DateFrom = $ReportTimes.CustomDate.DateFrom
            DateTo   = $ReportTimes.CustomDate.DateTo
        }
        if ($DatesCustom -ne $null) {
            $Dates += $DatesCustom
        }
    }
    if ($ReportTimes.Everything) {
        $DatesEverything = @{
            DateFrom = Get-Date -Year 1600 -Month 1 -Day 1
            DateTo   = Get-Date -Year 2300 -Month 1 -Day 1
        }
        $Dates += $DatesEverything
    }
    if ($ReportTimes.Contains('Last3days') -and $ReportTimes.Last3days.Enabled) {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 3
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            $Dates += $DatesCurrentDayMinusDaysX
        }
    }
    if ($ReportTimes.Contains('Last7days') -and $ReportTimes.Last7days.Enabled) {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 7
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            $Dates += $DatesCurrentDayMinusDaysX
        }
    }
    if ($ReportTimes.Contains('Last14days') -and $ReportTimes.Last14days.Enabled) {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 14
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            $Dates += $DatesCurrentDayMinusDaysX
        }
    }
    return  $Dates
}
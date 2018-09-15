function Get-ChoosenDates {
    param(
        $ReportTimes
    )
    $Dates = @()

    # Report Per Hour
    if ($ReportTimes.PastHour -eq $true) {
        $DatesPastHour = Find-DatesPastHour
        if ($DatesPastHour -ne $null) {
            $Dates += $DatesPastHour
        }
    }
    if ($ReportTimes.CurrentHour -eq $true) {
        $DatesCurrentHour = Find-DatesCurrentHour
        if ($DatesCurrentHour -ne $null) {
            $Dates += $DatesCurrentHour
        }
    }
    # Report Per Day
    if ($ReportTimes.PastDay -eq $true) {
        $DatesDayPrevious = Find-DatesDayPrevious
        if ($DatesDayPrevious -ne $null) {
            $Dates += $DatesDayPrevious
        }
    }
    if ($ReportTimes.CurrentDay -eq $true) {
        $DatesDayToday = Find-DatesDayToday
        if ($DatesDayToday -ne $null) {
            $Dates += $DatesDayToday
        }
    }
    # Report Per Week
    if ($ReportTimes.OnDay.Enabled -eq $true) {
        foreach ($Day in $ReportTimes.OnDay.Days) {
            $DatesReportOnDay = Find-DatesPastWeek $Day
            if ($DatesReportOnDay -ne $null) {
                $Dates += $DatesReportOnDay
            }
        }
    }
    # Report Per Month
    if ($ReportTimes.PastMonth.Enabled -eq $true -or $ReportTimes.PastMonth.Force -eq $true) {
        $DatesMonthPrevious = Find-DatesMonthPast -Force $ReportTimes.PastMonth.Force     # Find-DatesMonthPast runs only on 1st of the month unless -Force is used
        if ($DatesMonthPrevious -ne $null) {
            $Dates += $DatesMonthPrevious
        }
    }
    if ($ReportTimes.CurrentMonth -eq $true) {
        $DatesMonthCurrent = Find-DatesMonthCurrent
        if ($DatesMonthCurrent -ne $null) {
            $Dates += $DatesMonthCurrent
        }
    }
    # Report Per Quarter
    if ($ReportTimes.PastQuarter.Enabled -eq $true -or $ReportTimes.PastQuarter.Force -eq $true) {
        $DatesQuarterLast = Find-DatesQuarterLast -Force $ReportTimes.PastQuarter.Force  # Find-DatesMonthPast runs only on 1st of the quarter unless -Force is used
        if ($DatesQuarterLast -ne $null) {
            $Dates += $DatesQuarterLast
        }
    }
    if ($ReportTimes.CurrentQuarter -eq $true) {
        $DatesQuarterCurrent = Find-DatesQuarterCurrent
        if ($DatesQuarterCurrent -ne $null) {
            $Dates += $DatesQuarterCurrent
        }
    }
    # Report Custom
    if ($ReportTimes.CurrentDayMinusDayX.Enabled -eq $true) {
        $DatesCurrentDayMinusDayX = Find-DatesCurrentDayMinusDayX $ReportTimes.CurrentDayMinusDayX.Days
        if ($DatesCurrentDayMinusDayX -ne $null) {
            $Dates += $DatesCurrentDayMinusDayX
        }
    }
    if ($ReportTimes.CurrentDayMinuxDaysX.Enabled -eq $true) {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX $ReportTimes.CurrentDayMinuxDaysX.Days
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            $Dates += $DatesCurrentDayMinusDaysX
        }
    }
    if ($ReportTimes.CustomDate.Enabled -eq $true) {
        $DatesCustom = @{
            DateFrom = $ReportTimes.CustomDate.DateFrom
            DateTo   = $ReportTimes.CustomDate.DateTo
        }
        if ($DatesCustom -ne $null) {
            $Dates += $DatesCustom
        }
    }
    if ($ReportTimes.Everything -eq $true) {
        $DatesEverything = @{
            DateFrom = Get-Date -Year 1600 -Month 1 -Day 1
            DateTo   = Get-Date -Year 2300 -Month 1 -Day 1
        }
        $Dates += $DatesEverything
    }
    return  $Dates
}
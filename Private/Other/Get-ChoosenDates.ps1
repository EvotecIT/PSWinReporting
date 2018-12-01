function Get-ChoosenDates {
    param(
        [System.Collections.IDictionary] $ReportTimes
    )
    $Dates = @()

    # Report Per Hour
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'PastHour' -Key 'Enabled') {
        $DatesPastHour = Find-DatesPastHour
        if ($DatesPastHour -ne $null) {
            $Dates += $DatesPastHour
        }
    }
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'CurrentHour' -Key 'Enabled') {
        $DatesCurrentHour = Find-DatesCurrentHour
        if ($DatesCurrentHour -ne $null) {
            $Dates += $DatesCurrentHour
        }
    }
    # Report Per Day
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'PastDay' -Key 'Enabled') {
        $DatesDayPrevious = Find-DatesDayPrevious
        if ($DatesDayPrevious -ne $null) {
            $Dates += $DatesDayPrevious
        }
    }
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'CurrentDay' -Key 'Enabled') {
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
    if ($ReportTimes.PastMonth.Enabled -eq $true) {
        $DatesMonthPrevious = Find-DatesMonthPast -Force $ReportTimes.PastMonth.Force     # Find-DatesMonthPast runs only on 1st of the month unless -Force is used
        if ($DatesMonthPrevious -ne $null) {
            $Dates += $DatesMonthPrevious
        }
    }
    if (Test-KeyVerifyBoth -Object $ReportTimes.CurrentMonth -SubObject 'CurrentMonth' -Key 'Enabled') {
        $DatesMonthCurrent = Find-DatesMonthCurrent
        if ($DatesMonthCurrent -ne $null) {
            $Dates += $DatesMonthCurrent
        }
    }
    # Report Per Quarter
    if ($ReportTimes.PastQuarter.Enabled -eq $true) {
        $DatesQuarterLast = Find-DatesQuarterLast -Force $ReportTimes.PastQuarter.Force  # Find-DatesMonthPast runs only on 1st of the quarter unless -Force is used
        if ($DatesQuarterLast -ne $null) {
            $Dates += $DatesQuarterLast
        }
    }
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'CurrentQuarter' -Key 'Enabled') {
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
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'Everything' -Key 'Enabled') {
        $DatesEverything = @{
            DateFrom = Get-Date -Year 1600 -Month 1 -Day 1
            DateTo   = Get-Date -Year 2300 -Month 1 -Day 1
        }
        $Dates += $DatesEverything
    }
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'Last3days' -Key 'Enabled') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 3
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            $Dates += $DatesCurrentDayMinusDaysX
        }
    }
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'Last7days' -Key 'Enabled') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 7
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            $Dates += $DatesCurrentDayMinusDaysX
        }
    }
    if (Test-KeyVerifyBoth -Object $ReportTimes -SubObject 'Last14days' -Key 'Enabled') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 14
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            $Dates += $DatesCurrentDayMinusDaysX
        }
    }
    return  $Dates
}
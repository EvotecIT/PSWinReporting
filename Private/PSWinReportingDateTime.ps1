function Find-DatesQuarterLast ([bool] $Force) {
    #https://blogs.technet.microsoft.com/dsheehan/2017/09/21/use-powershell-to-determine-the-first-day-of-the-current-calendar-quarter/
    $Today = (Get-Date).AddDays(-90)
    $Yesterday = ((Get-Date).AddDays(-1))
    $Quarter = [Math]::Ceiling($Today.Month / 3)
    $LastDay = [DateTime]::DaysInMonth([Int]$Today.Year.ToString(), [Int]($Quarter * 3))
    $StartDate = (get-date -Year $Today.Year -Month ($Quarter * 3 - 2) -Day 1).Date
    $EndDate = (get-date -Year $Today.Year -Month ($Quarter * 3) -Day $LastDay).Date.AddDays(1).AddTicks(-1)

    if ($Force -eq $true -or $Yesterday.Date -eq $EndDate.Date) {
        $DateParameters = @{
            DateFrom = $StartDate
            DateTo   = $EndDate
        }
        return $DateParameters
    } else {
        return $null
    }
}
function Find-DatesQuarterCurrent ([bool] $Force) {
    $Today = (Get-Date)
    $Quarter = [Math]::Ceiling($Today.Month / 3)
    $LastDay = [DateTime]::DaysInMonth([Int]$Today.Year.ToString(), [Int]($Quarter * 3))
    $StartDate = (get-date -Year $Today.Year -Month ($Quarter * 3 - 2) -Day 1).Date
    $EndDate = (get-date -Year $Today.Year -Month ($Quarter * 3) -Day $LastDay).Date.AddDays(1).AddTicks(-1)
    $DateParameters = @{
        DateFrom = $StartDate
        DateTo   = $EndDate
    }
    return $DateParameters
}
function Find-DatesMonthPast ([bool] $Force) {
    $DateToday = (Get-Date).Date
    $DateMonthFirstDay = (GET-DATE -Day 1).Date
    $DateMonthPreviousFirstDay = $DateMonthFirstDay.AddMonths(-1)

    if ($Force -eq $true -or $DateToday -eq $DateMonthFirstDay) {
        $DateParameters = @{
            DateFrom = $DateMonthPreviousFirstDay
            DateTo   = $DateMonthFirstDay
        }
        return $DateParameters
    } else {
        return $null
    }
}
function Find-DatesMonthCurrent () {
    $DateMonthFirstDay = (GET-DATE -Day 1).Date
    $DateMonthLastDay = GET-DATE $DateMonthFirstDay.AddMonths(1).AddSeconds(-1)

    $DateParameters = @{
        DateFrom = $DateMonthFirstDay
        DateTo   = $DateMonthLastDay
    }
    return $DateParameters
}
function Find-DatesDayPrevious () {
    $DateToday = (GET-DATE).Date
    $DateYesterday = $DateToday.AddDays(-1)

    $DateParameters = @{
        DateFrom = $DateYesterday
        DateTo   = $dateToday
    }
    return $DateParameters
}
function Find-DatesDayToday () {
    $DateToday = (GET-DATE).Date
    $DateTodayEnd = $DateToday.AddDays(1).AddSeconds(-1)

    $DateParameters = @{
        DateFrom = $DateToday
        DateTo   = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesPastHour () {
    $DateTodayEnd = Get-Date -Minute 0 -Second 0 -Millisecond 0
    $DateTodayStart = $DateTodayEnd.AddHours(-1)

    $DateParameters = @{
        DateFrom = $DateTodayStart
        DateTo   = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesCurrentHour () {
    $DateTodayStart = (Get-Date -Minute 0 -Second 0 -Millisecond 0)
    $DateTodayEnd = $DateTodayStart.AddHours(1)

    $DateParameters = @{
        DateFrom = $DateTodayStart
        DateTo   = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesCurrentDayMinusDayX ($days) {
    $DateTodayStart = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays( - $Days)
    $DateTodayEnd = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(1).AddDays( - $Days).AddMilliseconds(-1)

    $DateParameters = @{
        DateFrom = $DateTodayStart
        DateTo   = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesCurrentDayMinuxDaysX ($days) {
    $DateTodayStart = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays( - $Days)
    $DateTodayEnd = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(1).AddMilliseconds(-1)

    $DateParameters = @{
        DateFrom = $DateTodayStart
        DateTo   = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesPastWeek($DayName) {
    $DateTodayStart = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0
    if ($DateTodayStart.DayOfWeek -ne $DayName) {
        return $null
    }
    $DateTodayEnd = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(-7)
    $DateParameters = @{
        DateFrom = $DateTodayEnd
        DateTo   = $DateTodayStart
    }
    return $DateParameters

}
function Get-TimeZoneLegacy () {
    return ([System.TimeZone]::CurrentTimeZone).StandardName
}
function Get-TimeZoneAdvanced {
    param(
        [string[]]$ComputerName = $Env:COMPUTERNAME,
        [System.Management.Automation.PSCredential] $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    foreach ($computer in $computerName) {
        $TimeZone = Get-WmiObject -Class win32_timezone -ComputerName $computer -Credential $Credential
        $LocalTime = Get-WmiObject -Class win32_localtime -ComputerName $computer -Credential $Credential
        $Output = @{
            'ComputerName' = $localTime.__SERVER;
            'TimeZone'     = $timeZone.Caption;
            'CurrentTime'  = (Get-Date -Day $localTime.Day -Month $localTime.Month);
        }
        $Object = New-Object -TypeName PSObject -Property $Output
        Write-Output $Object
    }
}
function Start-TimeLog() {
    $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
    return $ExecutionTime
}
function Stop-TimeLog([System.Diagnostics.Stopwatch] $Time) {
    $TimeToExecute = "$($Time.Elapsed.Days) days, $($Time.Elapsed.Hours) hours, $($Time.Elapsed.Minutes) minutes, $($Time.Elapsed.Seconds) seconds, $($Time.Elapsed.Milliseconds) milliseconds"
    $Time.Stop()
    return $TimeToExecute
}
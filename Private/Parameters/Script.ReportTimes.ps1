$Script:ReportTimes = [ordered] @{
    # Report Per Hour
    PastHour             = @{
        Enabled = $false # if it's 23:22 it will report 22:00 till 23:00
    }
    CurrentHour          = @{
        Enabled = $false # if it's 23:22 it will report 23:00 till 00:00
    }
    # Report Per Day
    PastDay              = @{
        Enabled = $false # if it's 1.04.2018 it will report 31.03.2018 00:00:00 till 01.04.2018 00:00:00
    }
    CurrentDay           = @{
        Enabled = $false # if it's 1.04.2018 05:22 it will report 1.04.2018 00:00:00 till 01.04.2018 00:00:00
    }
    # Report Per Week
    OnDay                = @{
        Enabled = $false
        Days    = 'Monday'#, 'Tuesday'
    }
    # Report Per Month
    PastMonth            = @{
        Enabled = $false # checks for 1st day of the month - won't run on any other day unless used force
        Force   = $true  # if true - runs always ...
    }
    CurrentMonth         = @{
        Enabled = $false
    }

    # Report Per Quarter
    PastQuarter          = @{
        Enabled = $false # checks for 1st day fo the quarter - won't run on any other day
        Force   = $true
    }
    CurrentQuarter       = @{
        Enabled = $false
    }
    # Report Custom
    CurrentDayMinusDayX  = @{
        Enabled = $false
        Days    = 7    # goes back X days and shows just 1 day
    }
    CurrentDayMinuxDaysX = @{
        Enabled = $false
        Days    = 3 # goes back X days and shows X number of days till Today
    }
    CustomDate           = @{
        Enabled  = $false
        DateFrom = get-date -Year 2018 -Month 03 -Day 19
        DateTo   = get-date -Year 2018 -Month 03 -Day 23
    }
    Last3days            = @{
        Enabled = $false
    }
    Last7days            = @{
        Enabled = $false
    }
    Last14days           = @{
        Enabled = $false

    }
    Everything           = @{
        Enabled = $false
    }
}
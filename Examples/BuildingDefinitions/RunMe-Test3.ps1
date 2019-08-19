﻿Import-Module .\PSWinReportingV2.psd1 -Force

$ReportDefinitions = [ordered] @{
    "OSStartupShutdownDetailed"         = [ordered]@{
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 1001, 1074
            LogName     = 'System'
            IgnoreWords = @{ }
            <#
            Fields      = [ordered] @{
                "Computer"        = "Computer"
                "StartTime"       = "Date"
                "MachineName"     = "ObjectAffected"
                "UserId"          = "SubjectUserSid"
                "NoNameB3"        = "EventLevel"
                "NoNameB4"        = "ShutdownDescription"
                "NoNameB6"        = "EventActionDetails"
                "EventAction"     = "EventAction"
                "NoNameB5"        = "ShutdownCode"
                "NoNameB7"        = "ShutdownComment"
                "ID"              = "Event ID"
                "RecordID"        = "Record ID"
                "GatheredFrom"    = "Gathered From"
                "GatheredLogName" = "Gathered LogName"
            }
            #>
            Overwrite   = @{
                "EventAction#1" = "Event ID", 1001, "Application crash"
                "EventAction#2" = "Event ID", 1074, "Shutdown initiated"
            }
        }
    }
}
$Target = [ordered]@{
    Servers           = [ordered] @{
        Enabled = $true
        #Server1 = @{ ComputerName = 'EVO1'; LogName = 'ForwardedEvents' }
        Server2 = 'AD1', 'AD2', 'AD3'
        #Server3 = 'AD1.ad.evo.xyz'
    }
    DomainControllers = [ordered] @{
        Enabled = $false
    }
    LocalFiles        = [ordered] @{
        Enabled     = $false
        Directories = [ordered] @{
            #MyEvents = 'C:\MyEvents' #
            #MyOtherEvent = 'C:\MyEvent1'
        }
        Files       = [ordered] @{
            #File1 = 'C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx'
        }
    }
}

$Times = @{
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
        Force   = $false  # if true - runs always ...
    }
    CurrentMonth         = @{
        Enabled = $true
    }

    # Report Per Quarter
    PastQuarter          = @{
        Enabled = $false # checks for 1st day fo the quarter - won't run on any other day
        Force   = $false # if true - runs always ...
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
        DateFrom = Get-Date -Year 2018 -Month 03 -Day 19
        DateTo   = Get-Date -Year 2018 -Month 03 -Day 23
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

$Mm = Find-Events -Definitions $ReportDefinitions -Times $Times -Target $Target
$mm | Out-HtmlView -AllProperties -ScrollX -DisablePaging

#| ft -a
return
foreach ($_ in $MM) {
    ($_.PSObject.Properties.Name).Count
}
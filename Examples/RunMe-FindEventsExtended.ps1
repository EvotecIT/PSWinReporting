Import-Module .\PSWinReportingV2.psd1 -Force

$DefinitionsADSync = @{
    AzureSynchronizationErrors  = @{
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 6100
            LogName     = 'Application'
            IgnoreWords = @{}

            Fields      = [ordered] @{
                'Computer'           = 'AD Connect Server'
                'Action'             = 'Action'
                #'Who'                = 'Who'
                'Date'               = 'When'
                #'ObjectAffected'     = 'User Affected'
                'LevelDisplayName'   = 'Level'
                'TaskDisplayName'    = 'Task'

                'NoNameA1'           = 'Profile Run'
                'NoNameA2'           = 'Discovery Errors'
                'NoNameA3'           = 'Synchronization Errors'
                'NoNameA4'           = 'Metaverse Retry Errors'
                'NoNameA5'           = 'Export Errors'
                'NoNameA6'           = 'Warnings'
                'KeywordDisplayName' = 'Keywords1'
                # Common Fields
                'ID'                 = 'Event ID'
                'RecordID'           = 'Record ID'
                'GatheredFrom'       = 'Gathered From'
                'GatheredLogName'    = 'Gathered LogName'
            }

            SortBy      = 'When'
        }
    }
    AzureSynchronizationObjects = @{
        Enabled                 = $true
        EventsRunProfile        = @{
            Enabled     = $true
            Events      = 6946
            LogName     = 'Application'
            IgnoreWords = @{}

            Fields      = [ordered] @{
                'Computer'           = 'AD Connect Server'
                'Action'             = 'Action'
                #'Who'                = 'Who'
                'Date'               = 'When'
                #'ObjectAffected'     = 'User Affected'
                'LevelDisplayName'   = 'Level'
                'TaskDisplayName'    = 'Task'

                'NoNameA1'           = 'Profile Run'

                'KeywordDisplayName' = 'Keywords1'
                # Common Fields
                'ID'                 = 'Event ID'
                'RecordID'           = 'Record ID'
                'GatheredFrom'       = 'Gathered From'
                'GatheredLogName'    = 'Gathered LogName'
            }

            SortBy      = 'When'
        }
        EventsInternalConnector = @{
            Enabled     = $true
            Events      = 6946
            LogName     = 'Application'
            IgnoreWords = @{}
            Filter      = @{
                'Action' = 'Internal Connector run settings:'
            }
            Fields      = [ordered] @{
                'Computer'           = 'AD Connect Server'
                'Action'             = 'Action'
                #'Who'                = 'Who'
                'Date'               = 'When'
                #'ObjectAffected'     = 'User Affected'
                'LevelDisplayName'   = 'Level'
                'TaskDisplayName'    = 'Task'

                'NoNameB1'           = 'NoNameB1'
                'NoNameB2'           = 'NoNameB2'
                'NoNameB3'           = 'NoNameB3'
                'NoNameB4'           = 'NoNameB4'
                'NoNameB5'           = 'NoNameB5'
                'NoNameB6'           = 'NoNameB6'
                'NoNameB7'           = 'NoNameB7'
                'NoNameB8'           = 'NoNameB8'
                'KeywordDisplayName' = 'Keywords1'
                # Common Fields
                'ID'                 = 'Event ID'
                'RecordID'           = 'Record ID'
                'GatheredFrom'       = 'Gathered From'
                'GatheredLogName'    = 'Gathered LogName'
            }

            SortBy      = 'When'
        }
    }
}

$Target = [ordered]@{
    Servers           = [ordered] @{
        Enabled = $true
        # Server1 = @{ ComputerName = 'EVO1'; LogName = 'ForwardedEvents' }
        # Server2 = 'AD1', 'AD2'
        Server1 = 'ADConnect.ad.evotec.xyz'
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
            File1 = 'C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx'
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

Find-Events -Definitions $DefinitionsADSync -Times $Times -Target $Target
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

Add-EventsDefinitions -Definitions $DefinitionsADSync
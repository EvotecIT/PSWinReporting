$LdapBindingsDetails         = @{
    Enabled = $false
    Events  = @{
        Enabled     = $true
        Events      = 2889
        LogName     = 'Directory Service'
        IgnoreWords = @{ }

        Fields      = [ordered] @{
            'Computer'         = 'Domain Controller'
            'Action'           = 'Action'
            'Date'             = 'When'
            'NoNameA0'         = 'Ip/Port'
            'NoNameA1'         = 'Account Name'
            'NoNameA2'         = 'Bind Type'
            'LevelDisplayName' = 'Level'
            'TaskDisplayName'  = 'Task'
            # Common Fields
            'ID'               = 'Event ID'
            'RecordID'         = 'Record ID'
            'GatheredFrom'     = 'Gathered From'
            'GatheredLogName'  = 'Gathered LogName'
        }
        Overwrite        = [ordered] @{
            "Bind Type#1" = "Bind Type", 0, "Unsigned"
            "Bind Type#2" = "Bind Type", 1, "Simple"
        }
        SortBy      = 'When'
    }
}
$LdapBindingsSummary = @{
    Enabled = $false
    Events  = @{
        Enabled     = $true
        Events      = 2887
        LogName     = 'Directory Service'
        IgnoreWords = @{ }

        Fields      = [ordered] @{
            'Computer'         = 'Domain Controller'
            'NoNameA0'         = 'Number of simple binds performed without SSL/TLS'
            'NoNameA1'         = 'Number of Negotiate/Kerberos/NTLM/Digest binds performed without signing'
            'Date'             = 'When'
            'LevelDisplayName' = 'Level'
            'TaskDisplayName'  = 'Task'
            # Common Fields
            'ID'               = 'Event ID'
            'RecordID'         = 'Record ID'
            'GatheredFrom'     = 'Gathered From'
            'GatheredLogName'  = 'Gathered LogName'
        }
        SortBy      = 'When'
    }
}
## Define reports
$Script:ReportDefinitions = @{
    ReportsAD = @{
        EventBased = @{
            UserChanges            = @{
                Enabled     = $false
                Events      = 4720, 4738
                LogName     = 'Security'
                IgnoreWords = ''
                Fields      = ''
            }
            UserStatus             = @{
                Enabled     = $false
                Events      = 4722, 4725, 4767, 4723, 4724, 4726
                LogName     = 'Security'
                IgnoreWords = ''
                Fields      = [ordered] @{
                    'Computer'        = 'Domain Controller'
                    'Action'          = 'Action'
                    'Who'             = 'Who'
                    'Date'            = 'When'
                    'ObjectAffected'  = 'User Affected'

                    # Common Fields, Usually not important for reporting
                    'ID'              = 'Event ID'
                    'RecordID'        = 'Record ID'
                    'GatheredFrom'    = 'Gathered From'
                    'GatheredLogName' = 'Gathered LogName'
                }
                SortBy      = 'When'
            }
            UserLockouts           = @{
                Enabled     = $false
                Events      = 4740
                LogName     = 'Security'
                IgnoreWords = ''
                Fields      = [ordered] @{
                    'Computer'         = 'Domain Controller'
                    'Action'           = 'Action'
                    'TargetDomainName' = 'Computer Lockout On'
                    'ObjectAffected'   = 'User Affected'
                    'Who'              = 'Reported By'
                    'Date'             = 'When'

                    # Common Fields, Usually not important for reporting
                    'ID'               = 'Event ID'
                    'RecordID'         = 'Record ID'
                    'GatheredFrom'     = 'Gathered From'
                    'GatheredLogName'  = 'Gathered LogName'
                }
                SortBy      = 'When'
            }
            UserLogon              = @{
                Enabled     = $false
                Events      = 4624
                LogName     = 'Security'
                IgnoreWords = ''
            }
            ComputerCreatedChanged = @{
                Enabled     = $false
                Events      = 4741, 4742 # created, changed
                LogName     = 'Security'
                IgnoreWords = ''
            }
            ComputerDeleted        = @{
                Enabled     = $false
                Events      = 4743 # deleted
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserLogonKerberos      = @{
                Enabled     = $false
                Events      = 4768
                LogName     = 'Security'
                IgnoreWords = ''
            }
            GroupMembershipChanges = @{
                Enabled     = $false
                Events      = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupCreateDelete      = @{
                Enabled     = $false
                Events      = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupPolicyChanges     = @{
                Enabled     = $false
                Events      = 5136, 5137, 5141
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedSecurity    = @{
                Enabled     = $false
                Events      = 1102, 1105
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedOther       = @{
                Enabled     = $false
                Events      = 104
                LogName     = 'System'
                IgnoreWords = ''
            }
            EventsReboots          = @{
                Enabled     = $false
                Events      = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013
                LogName     = 'System'
                IgnoreWords = ''
            }
        }
    }
}
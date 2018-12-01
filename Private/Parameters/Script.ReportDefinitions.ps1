## Define reports
$Script:ReportDefinitions = @{
    ReportsAD = @{
        EventBased = @{
            UserChanges            = @{
                Enabled     = $false
                Events      = 4720, 4738
                LogName     = 'Security'
                Fields      = [ordered] @{
                    'Computer'            = 'Domain Controller'
                    'Action'              = 'Action'
                    'ObjectAffected'      = 'User Affected'
                    'SamAccountName'      = 'SamAccountName'
                    'DisplayName'         = 'DisplayName'
                    'UserPrincipalName'   = 'UserPrincipalName'
                    'HomeDirectory'       = 'Home Directory'
                    'HomePath'            = 'Home Path'
                    'ScriptPath'          = 'Script Path'
                    'ProfilePath'         = 'Profile Path'
                    'UserWorkstations'    = 'User Workstations'
                    'PasswordLastSet'     = 'Password Last Set'
                    'AccountExpires'      = 'Account Expires'
                    'PrimaryGroupId'      = 'Primary Group Id'
                    'AllowedToDelegateTo' = 'Allowed To Delegate To'
                    'OldUacValue'         = 'Old Uac Value'
                    'NewUacValue'         = 'New Uac Value'
                    'UserAccountControl'  = 'User Account Control'
                    'UserParameters'      = 'User Parameters'
                    'SidHistory'          = 'Sid History'
                    'Who'                 = 'Who'
                    'Date'                = 'When'
                    # Common Fields
                    'ID'                  = 'Event ID'
                    'RecordID'            = 'Record ID'
                    'GatheredFrom'        = 'Gathered From'
                    'GatheredLogName'     = 'Gathered LogName'
                }
                Ignore      = @{
                    # Cleanup Anonymous LOGON (usually related to password events)
                    # https://social.technet.microsoft.com/Forums/en-US/5b2a93f7-7101-43c1-ab53-3a51b2e05693/eventid-4738-user-account-was-changed-by-anonymous?forum=winserverDS
                    SubjectUserName = "ANONYMOUS LOGON"

                    # Test value
                    ProfilePath     = 'C*'
                }
                Functions   = @{
                    'ProfilePath'        = 'Convert-UAC'
                    'OldUacValue'        = 'Remove-WhiteSpace', 'Convert-UAC'
                    'NewUacValue'        = 'Remove-WhiteSpace', 'Convert-UAC'
                    'UserAccountControl' = 'Remove-WhiteSpace', 'SplitOnSpace', 'Convert-UAC'
                }
                IgnoreWords = @{
                    'Profile Path' = 'TEMP*'
                }
                SortBy      = 'When'
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

                    # Common Fields
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

                    # Common Fields
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
                Fields      = [ordered] @{
                    'Computer'            = 'Domain Controller'
                    'Action'              = 'Action'
                    'ObjectAffected'      = 'Computer Affected'
                    'SamAccountName'      = 'SamAccountName'
                    'DisplayName'         = 'DisplayName'
                    'UserPrincipalName'   = 'UserPrincipalName'
                    'HomeDirectory'       = 'Home Directory'
                    'HomePath'            = 'Home Path'
                    'ScriptPath'          = 'Script Path'
                    'ProfilePath'         = 'Profile Path'
                    'UserWorkstations'    = 'User Workstations'
                    'PasswordLastSet'     = 'Password Last Set'
                    'AccountExpires'      = 'Account Expires'
                    'PrimaryGroupId'      = 'Primary Group Id'
                    'AllowedToDelegateTo' = 'Allowed To Delegate To'
                    'OldUacValue'         = 'Old Uac Value'
                    'NewUacValue'         = 'New Uac Value'
                    'UserAccountControl'  = 'User Account Control'
                    'UserParameters'      = 'User Parameters'
                    'SidHistory'          = 'Sid History'
                    'Who'                 = 'Who'
                    'Date'                = 'When'
                    # Common Fields
                    'ID'                  = 'Event ID'
                    'RecordID'            = 'Record ID'
                    'GatheredFrom'        = 'Gathered From'
                    'GatheredLogName'     = 'Gathered LogName'
                }
                Ignore      = @{
                    # Cleanup Anonymous LOGON (usually related to password events)
                    # https://social.technet.microsoft.com/Forums/en-US/5b2a93f7-7101-43c1-ab53-3a51b2e05693/eventid-4738-user-account-was-changed-by-anonymous?forum=winserverDS
                    SubjectUserName = "ANONYMOUS LOGON"
                }
            }
            ComputerDeleted        = @{
                Enabled     = $false
                Events      = 4743 # deleted
                LogName     = 'Security'
                IgnoreWords = ''
                Fields      = [ordered] @{
                    'Computer'        = 'Domain Controller'
                    'Action'          = 'Action'
                    'ObjectAffected'  = 'Computer Affected'
                    'Who'             = 'Who'
                    'Date'            = 'When'

                    # Common Fields
                    'ID'              = 'Event ID'
                    'RecordID'        = 'Record ID'
                    'GatheredFrom'    = 'Gathered From'
                    'GatheredLogName' = 'Gathered LogName'
                }
                SortBy      = 'When'
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
                Fields      = [ordered] @{
                    'Computer'            = 'Domain Controller'
                    'Action'              = 'Action'
                    'TargetUserName'      = 'Group Name'
                    'MemberNameWithoutCN' = 'Member Name' # Required work {$_.MemberName -replace '^CN=|,.*$' }}, fixed in PSEventViewer
                    'Who'                 = 'Who'
                    'Date'                = 'When'

                    # Common Fields
                    'ID'                  = 'Event ID'
                    'RecordID'            = 'Record ID'
                    'GatheredFrom'        = 'Gathered From'
                    'GatheredLogName'     = 'Gathered LogName'
                }
                SortBy      = 'When'
            }
            GroupCreateDelete      = @{
                Enabled     = $false
                Events      = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
                Fields      = [ordered] @{
                    'Computer'        = 'Domain Controller'
                    'Action'          = 'Action'
                    'TargetUserName'  = 'Group Name'
                    'Who'             = 'Who'
                    'Date'            = 'When'

                    # Common Fields
                    'ID'              = 'Event ID'
                    'RecordID'        = 'Record ID'
                    'GatheredFrom'    = 'Gathered From'
                    'GatheredLogName' = 'Gathered LogName'
                }
                SortBy      = 'When'
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
                Fields      = [ordered] @{
                    'Computer'        = 'Domain Controller'
                    'Action'          = 'Action'
                    'BackupPath'      = 'Backup Path'
                    'Channel'         = 'Log Type'

                    'Who'             = 'Who'
                    'Date'            = 'When'

                    # Common Fields
                    'ID'              = 'Event ID'
                    'RecordID'        = 'Record ID'
                    'GatheredFrom'    = 'Gathered From'
                    'GatheredLogName' = 'Gathered LogName'
                }
                SortBy      = 'When'
                Overwrite   = @{
                    'Who' = 'ID', 1105, 'Automatic Backup'  # if event id 1105 set field to Automatic Backup
                }
            }
            LogsClearedOther       = @{
                Enabled     = $false
                Events      = 104
                LogName     = 'System'
                IgnoreWords = ''
                Fields      = [ordered] @{
                    'Computer'        = 'Domain Controller'
                    'Action'          = 'Action'
                    'TargetUserName'  = 'Group Name'
                    'Who'             = 'Who'
                    'Date'            = 'When'

                    # Common Fields
                    'ID'              = 'Event ID'
                    'RecordID'        = 'Record ID'
                    'GatheredFrom'    = 'Gathered From'
                    'GatheredLogName' = 'Gathered LogName'
                }
                SortBy      = 'When'
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
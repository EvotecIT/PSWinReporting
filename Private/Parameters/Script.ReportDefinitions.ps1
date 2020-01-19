## Define reports
$Script:ReportDefinitions = [ordered] @{
    ADUserChanges                       = @{
        Enabled   = $false
        SqlExport = @{
            EnabledGlobal         = $false
            Enabled               = $false
            SqlServer             = 'EVO1'
            SqlDatabase           = 'SSAE18'
            SqlTable              = 'dbo.[EventsNewSpecial]'
            # Left side is data in PSWinReporting. Right Side is ColumnName in SQL
            # Changing makes sense only for right side...
            SqlTableCreate        = $true
            SqlTableAlterIfNeeded = $false # if table mapping is defined doesn't do anything
            SqlCheckBeforeInsert  = 'EventRecordID', 'DomainController' # Based on column name
            SqlTableMapping       = [ordered] @{
                'Event ID'               = 'EventID,[int]'
                'Who'                    = 'EventWho'
                'When'                   = 'EventWhen,[datetime]'
                'Record ID'              = 'EventRecordID,[bigint]'
                'Domain Controller'      = 'DomainController'
                'Action'                 = 'Action'
                'Group Name'             = 'GroupName'
                'User Affected'          = 'UserAffected'
                'Member Name'            = 'MemberName'
                'Computer Lockout On'    = 'ComputerLockoutOn'
                'Reported By'            = 'ReportedBy'
                'SamAccountName'         = 'SamAccountName'
                'Display Name'           = 'DisplayName'
                'UserPrincipalName'      = 'UserPrincipalName'
                'Home Directory'         = 'HomeDirectory'
                'Home Path'              = 'HomePath'
                'Script Path'            = 'ScriptPath'
                'Profile Path'           = 'ProfilePath'
                'User Workstation'       = 'UserWorkstation'
                'Password Last Set'      = 'PasswordLastSet'
                'Account Expires'        = 'AccountExpires'
                'Primary Group Id'       = 'PrimaryGroupId'
                'Allowed To Delegate To' = 'AllowedToDelegateTo'
                'Old Uac Value'          = 'OldUacValue'
                'New Uac Value'          = 'NewUacValue'
                'User Account Control'   = 'UserAccountControl'
                'User Parameters'        = 'UserParameters'
                'Sid History'            = 'SidHistory'
                'Logon Hours'            = 'LogonHours'
                'OperationType'          = 'OperationType'
                'Message'                = 'Message'
                'Backup Path'            = 'BackupPath'
                'Log Type'               = 'LogType'
                'AddedWhen'              = 'EventAdded,[datetime],null' # ColumnsToTrack when it was added to database and by who / not part of event
                'AddedWho'               = 'EventAddedWho'  # ColumnsToTrack when it was added to database and by who / not part of event
                'Gathered From'          = 'GatheredFrom'
                'Gathered LogName'       = 'GatheredLogName'
            }
        }
        Events    = @{
            Enabled     = $true
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
                #ProfilePath     = 'C*'
            }
            Functions   = @{
                'ProfilePath'        = 'Convert-UAC'
                'OldUacValue'        = 'Remove-WhiteSpace', 'Convert-UAC'
                'NewUacValue'        = 'Remove-WhiteSpace', 'Convert-UAC'
                'UserAccountControl' = 'Remove-WhiteSpace', 'Split-OnSpace', 'Convert-UAC'
            }
            IgnoreWords = @{
                #'Profile Path' = 'TEMP*'
            }
            SortBy      = 'When'
        }
    }
    ADUserChangesDetailed               = [ordered] @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 5136, 5137, 5139, 5141
            LogName     = 'Security'
            Filter      = [ordered] @{
                'ObjectClass' = 'user'
            }
            Functions   = @{
                'OperationType' = 'ConvertFrom-OperationType'
            }
            Fields      = [ordered] @{
                'Computer'                 = 'Domain Controller'
                'Action'                   = 'Action'
                'OperationType'            = 'Action Detail'
                'Who'                      = 'Who'
                'Date'                     = 'When'
                'ObjectDN'                 = 'User Object'
                'AttributeLDAPDisplayName' = 'Field Changed'
                'AttributeValue'           = 'Field Value'
                # Common Fields
                'RecordID'                 = 'Record ID'
                'ID'                       = 'Event ID'
                'GatheredFrom'             = 'Gathered From'
                'GatheredLogName'          = 'Gathered LogName'
            }

            SortBy      = 'Record ID'
            Descending  = $false
            IgnoreWords = @{

            }
        }
    }
    ADComputerChangesDetailed           = [ordered] @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 5136, 5137, 5139, 5141
            LogName     = 'Security'
            Filter      = @{
                'ObjectClass' = 'computer'
            }
            Functions   = @{
                'OperationType' = 'ConvertFrom-OperationType'
            }
            Fields      = [ordered] @{
                'Computer'                 = 'Domain Controller'
                'Action'                   = 'Action'
                'OperationType'            = 'Action Detail'
                'Who'                      = 'Who'
                'Date'                     = 'When'
                'ObjectDN'                 = 'Computer Object'
                'AttributeLDAPDisplayName' = 'Field Changed'
                'AttributeValue'           = 'Field Value'
                # Common Fields
                'RecordID'                 = 'Record ID'
                'ID'                       = 'Event ID'
                'GatheredFrom'             = 'Gathered From'
                'GatheredLogName'          = 'Gathered LogName'
            }
            SortBy      = 'Record ID'
            Descending  = $false
            IgnoreWords = @{ }
        }
    }
    ADOrganizationalUnitChangesDetailed = [ordered] @{
        Enabled        = $false
        OUEventsModify = @{
            Enabled          = $true
            Events           = 5136, 5137, 5139, 5141
            LogName          = 'Security'
            Filter           = [ordered] @{
                'ObjectClass' = 'organizationalUnit'
            }
            Functions        = @{
                'OperationType' = 'ConvertFrom-OperationType'
            }

            Fields           = [ordered] @{
                'Computer'                 = 'Domain Controller'
                'Action'                   = 'Action'
                'OperationType'            = 'Action Detail'
                'Who'                      = 'Who'
                'Date'                     = 'When'
                'ObjectDN'                 = 'Organizational Unit'
                'AttributeLDAPDisplayName' = 'Field Changed'
                'AttributeValue'           = 'Field Value'
                #'OldObjectDN'              = 'OldObjectDN'
                #'NewObjectDN'              = 'NewObjectDN'
                # Common Fields
                'RecordID'                 = 'Record ID'
                'ID'                       = 'Event ID'
                'GatheredFrom'             = 'Gathered From'
                'GatheredLogName'          = 'Gathered LogName'
            }
            Overwrite        = [ordered] @{
                'Action Detail#1' = 'Action', 'A directory service object was created.', 'Organizational Unit Created'
                'Action Detail#2' = 'Action', 'A directory service object was deleted.', 'Organizational Unit Deleted'
                'Action Detail#3' = 'Action', 'A directory service object was moved.', 'Organizational Unit Moved'
                #'Organizational Unit' = 'Action', 'A directory service object was moved.', 'OldObjectDN'
                #'Field Changed'       = 'Action', 'A directory service object was moved.', ''
                #'Field Value'         = 'Action', 'A directory service object was moved.', 'NewObjectDN'
            }
            # This Overwrite works in a way where you can swap one value with another value from another field within same Event
            # It's useful if you have an event that already has some fields used but empty and you wnat to utilize them
            # for some content
            OverwriteByField = [ordered] @{
                'Organizational Unit' = 'Action', 'A directory service object was moved.', 'OldObjectDN'
                #'Field Changed'       = 'Action', 'A directory service object was moved.', ''
                'Field Value'         = 'Action', 'A directory service object was moved.', 'NewObjectDN'
            }
            SortBy           = 'Record ID'
            Descending       = $false
            IgnoreWords      = @{ }
        }
    }
    ADUserStatus                        = [ordered] @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4722, 4725, 4767, 4723, 4724, 4726
            LogName     = 'Security'
            IgnoreWords = @{ }
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
    }
    ADUserLockouts                      = [ordered] @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4740
            LogName     = 'Security'
            IgnoreWords = @{ }
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
    }
    ADUserLogon                         = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4624
            LogName     = 'Security'
            Fields      = [ordered] @{
                'Computer'           = 'Computer'
                'Action'             = 'Action'
                'IpAddress'          = 'IpAddress'
                'IpPort'             = 'IpPort'
                'ObjectAffected'     = 'User / Computer Affected'
                'Who'                = 'Who'
                'Date'               = 'When'
                'LogonProcessName'   = 'LogonProcessName'
                'ImpersonationLevel' = 'ImpersonationLevel' # %%1833 = Impersonation
                'VirtualAccount'     = 'VirtualAccount'  #  %%1843 = No
                'ElevatedToken'      = 'ElevatedToken' # %%1842 = Yes
                'LogonType'          = 'LogonType'
                # Common Fields
                'ID'                 = 'Event ID'
                'RecordID'           = 'Record ID'
                'GatheredFrom'       = 'Gathered From'
                'GatheredLogName'    = 'Gathered LogName'
            }
            IgnoreWords = @{ }
        }
    }
    ADUserUnlocked                      = [ordered] @{
        # 4767	A user account was unlocked
        # https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4767
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4767
            LogName     = 'Security'
            IgnoreWords = @{ }
            Functions   = @{ }
            Fields      = [ordered] @{
                'Computer'         = 'Domain Controller'
                'Action'           = 'Action'
                'TargetDomainName' = 'Computer Lockout On'
                'ObjectAffected'   = 'User Affected'
                'Who'              = 'Who'
                'Date'             = 'When'
                # Common Fields
                'ID'               = 'Event ID'
                'RecordID'         = 'Record ID'
                'GatheredFrom'     = 'Gathered From'
                'GatheredLogName'  = 'Gathered LogName'
            }
            SortBy      = 'When'
        }
    }
    ADComputerCreatedChanged            = [ordered] @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4741, 4742 # created, changed
            LogName     = 'Security'
            Ignore      = @{
                # Cleanup Anonymous LOGON (usually related to password events)
                # https://social.technet.microsoft.com/Forums/en-US/5b2a93f7-7101-43c1-ab53-3a51b2e05693/eventid-4738-user-account-was-changed-by-anonymous?forum=winserverDS
                SubjectUserName = "ANONYMOUS LOGON"
            }
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
            IgnoreWords = @{ }
        }
    }
    ADComputerDeleted                   = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4743 # deleted
            LogName     = 'Security'
            IgnoreWords = @{ }
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
    }
    ADUserLogonKerberos                 = [ordered] @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4768
            LogName     = 'Security'
            IgnoreWords = @{ }
            Functions   = [ordered] @{
                'IpAddress' = 'Clean-IpAddress'
            }
            Fields      = [ordered] @{
                'Computer'             = 'Domain Controller'
                'Action'               = 'Action'
                'ObjectAffected'       = 'Computer/User Affected'
                'IpAddress'            = 'IpAddress'
                'IpPort'               = 'Port'
                'TicketOptions'        = 'TicketOptions'
                'Status'               = 'Status'
                'TicketEncryptionType' = 'TicketEncryptionType'
                'PreAuthType'          = 'PreAuthType'
                'Date'                 = 'When'

                # Common Fields
                'ID'                   = 'Event ID'
                'RecordID'             = 'Record ID'
                'GatheredFrom'         = 'Gathered From'
                'GatheredLogName'      = 'Gathered LogName'
            }
            SortBy      = 'When'
        }
    }
    ADGroupMembershipChanges            = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4728, 4729, 4732, 4733, 4746, 4747, 4751, 4752, 4756, 4757, 4761, 4762, 4785, 4786, 4787, 4788
            LogName     = 'Security'
            IgnoreWords = @{
                #'Who' = '*ANONYMOUS*'
            }
            Fields      = [ordered] @{
                'Computer'            = 'Domain Controller'
                'Action'              = 'Action'
                'TargetUserName'      = 'Group Name'
                'MemberNameWithoutCN' = 'Member Name'
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
    }
    ADGroupEnumeration                  = [ordered] @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4798, 4799
            LogName     = 'Security'
            IgnoreWords = [ordered] @{
                #'Who' = '*ANONYMOUS*'
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
    }
    ADGroupChanges                      = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4735, 4737, 4745, 4750, 4760, 4764, 4784, 4791
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
                'GroupTypeChange' = 'Changed Group Type'
                'SamAccountName'  = 'Changed SamAccountName'
                'SidHistory'      = 'Changed SidHistory'

                # Common Fields
                'ID'              = 'Event ID'
                'RecordID'        = 'Record ID'
                'GatheredFrom'    = 'Gathered From'
                'GatheredLogName' = 'Gathered LogName'
            }

            SortBy      = 'When'
        }
    }
    ADGroupCreateDelete                 = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4727, 4730, 4731, 4734, 4744, 4748, 4749, 4753, 4754, 4758, 4759, 4763
            LogName     = 'Security'
            IgnoreWords = @{
                #  'Who' = '*ANONYMOUS*'
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
    }
    ADGroupChangesDetailed              = [ordered] @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 5136, 5137, 5141
            LogName     = 'Security'
            Filter      = [ordered] @{
                # Filter is special
                # if there is just one object on the right side it will filter on that field
                # if there are more objects filter will pick all values on the right side and display them (using AND)
                'ObjectClass' = 'group'
            }
            Functions   = @{
                'OperationType' = 'ConvertFrom-OperationType'
            }
            Fields      = [ordered] @{
                'Computer'                 = 'Domain Controller'
                'Action'                   = 'Action'
                'OperationType'            = 'Action Detail'
                'Who'                      = 'Who'
                'Date'                     = 'When'
                'ObjectDN'                 = 'Computer Object'
                'ObjectClass'              = 'ObjectClass'
                'AttributeLDAPDisplayName' = 'Field Changed'
                'AttributeValue'           = 'Field Value'
                # Common Fields
                'RecordID'                 = 'Record ID'
                'ID'                       = 'Event ID'
                'GatheredFrom'             = 'Gathered From'
                'GatheredLogName'          = 'Gathered LogName'
            }

            SortBy      = 'Record ID'
            Descending  = $false
            IgnoreWords = @{

            }
        }
    }
    ADGroupPolicyChanges                = [ordered] @{
        Enabled                     = $false
        'Group Policy Name Changes' = @{
            Enabled     = $true
            Events      = 5136, 5137, 5141
            LogName     = 'Security'
            Filter      = [ordered] @{
                # Filter is special, if there is just one object on the right side
                # If there are more objects filter will pick all values on the right side and display them as required
                'ObjectClass'              = 'groupPolicyContainer'
                #'OperationType'            = 'Value Added'
                'AttributeLDAPDisplayName' = $null, 'displayName' #, 'versionNumber'
            }
            Functions   = @{
                'OperationType' = 'ConvertFrom-OperationType'
            }
            Fields      = [ordered] @{
                'RecordID'                 = 'Record ID'
                'Computer'                 = 'Domain Controller'
                'Action'                   = 'Action'
                'Who'                      = 'Who'
                'Date'                     = 'When'


                'ObjectDN'                 = 'ObjectDN'
                'ObjectGUID'               = 'ObjectGUID'
                'ObjectClass'              = 'ObjectClass'
                'AttributeLDAPDisplayName' = 'AttributeLDAPDisplayName'
                #'AttributeSyntaxOID'       = 'AttributeSyntaxOID'
                'AttributeValue'           = 'AttributeValue'
                'OperationType'            = 'OperationType'
                'OpCorrelationID'          = 'OperationCorelationID'
                'AppCorrelationID'         = 'OperationApplicationCorrelationID'

                'DSName'                   = 'DSName'
                'DSType'                   = 'DSType'
                'Task'                     = 'Task'
                'Version'                  = 'Version'

                # Common Fields
                'ID'                       = 'Event ID'

                'GatheredFrom'             = 'Gathered From'
                'GatheredLogName'          = 'Gathered LogName'
            }

            SortBy      = 'Record ID'
            Descending  = $false
            IgnoreWords = @{

            }
        }
        'Group Policy Edits'        = @{
            Enabled     = $true
            Events      = 5136, 5137, 5141
            LogName     = 'Security'
            Filter      = [ordered] @{
                # Filter is special, if there is just one object on the right side
                # If there are more objects filter will pick all values on the right side and display them as required
                'ObjectClass'              = 'groupPolicyContainer'
                #'OperationType'            = 'Value Added'
                'AttributeLDAPDisplayName' = 'versionNumber'
            }
            Functions   = @{
                'OperationType' = 'ConvertFrom-OperationType'
            }
            Fields      = [ordered] @{
                'RecordID'                 = 'Record ID'
                'Computer'                 = 'Domain Controller'
                'Action'                   = 'Action'
                'Who'                      = 'Who'
                'Date'                     = 'When'


                'ObjectDN'                 = 'ObjectDN'
                'ObjectGUID'               = 'ObjectGUID'
                'ObjectClass'              = 'ObjectClass'
                'AttributeLDAPDisplayName' = 'AttributeLDAPDisplayName'
                #'AttributeSyntaxOID'       = 'AttributeSyntaxOID'
                'AttributeValue'           = 'AttributeValue'
                'OperationType'            = 'OperationType'
                'OpCorrelationID'          = 'OperationCorelationID'
                'AppCorrelationID'         = 'OperationApplicationCorrelationID'

                'DSName'                   = 'DSName'
                'DSType'                   = 'DSType'
                'Task'                     = 'Task'
                'Version'                  = 'Version'

                # Common Fields
                'ID'                       = 'Event ID'

                'GatheredFrom'             = 'Gathered From'
                'GatheredLogName'          = 'Gathered LogName'
            }

            SortBy      = 'Record ID'
            Descending  = $false
            IgnoreWords = @{

            }
        }
        'Group Policy Links'        = @{
            Enabled     = $true
            Events      = 5136, 5137, 5141
            LogName     = 'Security'
            Filter      = @{
                # Filter is special, if there is just one object on the right side
                # If there are more objects filter will pick all values on the right side and display them as required
                'ObjectClass' = 'domainDNS'
                #'OperationType'            = 'Value Added'
                #'AttributeLDAPDisplayName' = 'versionNumber'
            }
            Functions   = @{
                'OperationType' = 'ConvertFrom-OperationType'
            }
            Fields      = [ordered] @{
                'RecordID'                 = 'Record ID'
                'Computer'                 = 'Domain Controller'
                'Action'                   = 'Action'
                'Who'                      = 'Who'
                'Date'                     = 'When'


                'ObjectDN'                 = 'ObjectDN'
                'ObjectGUID'               = 'ObjectGUID'
                'ObjectClass'              = 'ObjectClass'
                'AttributeLDAPDisplayName' = 'AttributeLDAPDisplayName'
                #'AttributeSyntaxOID'       = 'AttributeSyntaxOID'
                'AttributeValue'           = 'AttributeValue'
                'OperationType'            = 'OperationType'
                'OpCorrelationID'          = 'OperationCorelationID'
                'AppCorrelationID'         = 'OperationApplicationCorrelationID'

                'DSName'                   = 'DSName'
                'DSType'                   = 'DSType'
                'Task'                     = 'Task'
                'Version'                  = 'Version'

                # Common Fields
                'ID'                       = 'Event ID'

                'GatheredFrom'             = 'Gathered From'
                'GatheredLogName'          = 'Gathered LogName'
            }

            SortBy      = 'Record ID'
            Descending  = $false
            IgnoreWords = @{

            }
        }
    }
    ADLogsClearedSecurity               = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 1102, 1105
            LogName     = 'Security'
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
                #'Test' = 'Test'
            }
            SortBy      = 'When'
            IgnoreWords = @{ }
            Overwrite   = [ordered] @{
                # Allows to overwrite field content on the fly, either only on IF or IF ELSE
                # IF <VALUE> -eq <VALUE> THEN <VALUE> (3 VALUES)
                # IF <VALUE> -eq <VALUE> THEN <VALUE> ELSE <VALUE> (4 VALUES)
                # If you need to use IF multiple times for same field use #1, #2 and so on to distinguish HashTable Key.

                'Backup Path' = 'Backup Path', '', 'N/A'
                #'Backup Path#1' = 'Backup Path', 'C:\Windows\System32\Winevt\Logs\Archive-Security-2018-11-24-09-25-36-988.evtx', 'MMMM'
                'Who'         = 'Event ID', 1105, 'Automatic Backup'  # if event id 1105 set field to Automatic Backup
                #'Test' = 'Event ID', 1106, 'Test', 'Mama mia'
            }
        }
    }
    ADLogsClearedOther                  = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 104
            LogName     = 'System'
            IgnoreWords = @{ }
            Fields      = [ordered] @{
                'Computer'     = 'Domain Controller'
                'Action'       = 'Action'
                'BackupPath'   = 'Backup Path'
                'Channel'      = 'Log Type'

                'Who'          = 'Who'
                'Date'         = 'When'

                # Common Fields
                'ID'           = 'Event ID'
                'RecordID'     = 'Record ID'
                'GatheredFrom' = 'Gathered From'
            }
            SortBy      = 'When'
            Overwrite   = @{
                # Allows to overwrite field content on the fly, either only on IF or IF ELSE
                # IF <VALUE> -eq <VALUE> THEN <VALUE> (3 VALUES)
                # IF <VALUE> -eq <VALUE> THEN <VALUE> ELSE <VALUE> (4 VALUES)
                # If you need to use IF multiple times for same field use spaces to distinguish HashTable Key.

                'Backup Path' = 'Backup Path', '', 'N/A'
            }
        }
    }
    NetworkAccessAuthenticationPolicy   = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 6272, 6273
            LogName     = 'Security'
            IgnoreWords = @{ }
            Fields      = [ordered] @{
                'Action'                        = 'Action'

                'SubjectUserSid'                = 'SecurityID'
                'Computer'                      = 'Compuer'

                'SubjectUserName'               = 'AccountName'
                'SubjectDomainName'             = 'Account Domain'

                'CalledStationID'               = 'CalledStationID'
                'CallingStationID'              = 'CallingStationID'

                # NAS
                'NASIPv4Address'                = 'NASIPv4Address'
                'NASIPv6Address'                = 'NASIPv6Address'
                'NASIdentifier'                 = 'NASIdentifier'
                'NASPortType'                   = 'NASPortType'
                'NASPort'                       = 'NASPort'

                # Radius Client
                'ClientName'                    = 'ClientFriendlyName'
                'ClientIPAddress'               = 'ClientFriendlyIPAddress'

                # Authentication Details
                'ProxyPolicyName'               = 'ConnectionRequestPolicyName'
                'NetworkPolicyName'             = 'NetworkPolicyName'
                'AuthenticationProvider'        = 'AuthenticationProvider'
                'AuthenticationServer'          = 'AuthenticationServer'
                'AuthenticationType'            = 'AuthenticationType'
                'EAPType'                       = 'EAPType'

                #'LoggingResult'          = 'LoggingResult' # Useless
                'Reason'                        = 'Reason'
                'ReasonCode'                    = 'ReasonCode'


                #'Version'                = 'Version'
                'FullyQualifiedSubjectUserName' = 'Who'
                'Date'                          = 'When'
                # Common Fields
                'ID'                            = 'Event ID'
                'RecordID'                      = 'Record ID'
                'GatheredFrom'                  = 'Gathered From'
                'GatheredLogName'               = 'Gathered LogName'
            }
            SortBy      = 'When'
        }
    }
    "OSCrash"                           = [ordered]@{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 6008
            LogName     = 'System'
            IgnoreWords = @{ }

            Fields      = [ordered] @{
                "Computer"        = "Computer"
                'Date'            = 'When'
                "MachineName"     = "ObjectAffected"
                "EventAction"     = "Action"
                #"NoNameB4"        = "EventLevel"
                "Message"         = "ActionDetails"
                "NoNameA1"        = "ActionDetailsDate"
                "NoNameA0"        = "ActionDetailsTime"
                #"NoNameB7"        = "EventSource"
                "ID"              = "Event ID"
                "RecordID"        = "Record ID"
                "GatheredFrom"    = "Gathered From"
                "GatheredLogName" = "Gathered LogName"
            }
            #>

            Overwrite   = @{
                "Action#1" = "Event ID" , 6008, "System Crash"
            }
        }
    }
    "OSStartupShutdownCrash"            = [ordered]@{
        Enabled = $false
        Events  = [ordered] @{
            Enabled          = $true
            Events           = 12, 13, 41, 4608, 4621, 6008
            #Events           = 13
            LogName          = 'System'
            IgnoreWords      = @{ }

            Filter           = [ordered] @{
                # This means each separate line is treated with AND and each entry in one line is treated with OR

                'ProviderName' = 'Microsoft-Windows-Kernel-General', 'EventLog'
                #'GatheredFrom' = 'AD1'
                #'NoNameA4' = '66','65'
                #'LevelDisplayName' = 'Warning'
                #'ProviderName' = 'Microsoft-Windows-Kernel-General', 'EventLog'
                #'ProviderName1'     = 'EventLog'
                # Filter is special, if there is just one object on the right side
                # If there are more objects filter will pick all values on the right side and display them as required
                # 'ObjectClass'              = 'groupPolicyContainer'
                #'OperationType'            = 'Value Added'
                #  'AttributeLDAPDisplayName' = 'versionNumber'
            }
            FilterOr         = [ordered] @{
                #'ProviderName#ne' = 'Microsoft-Windows-Kernel-General', 'EventLog'
                #'ProviderName#Like' = 'Microsoft-Windows*'
                #'ProviderName#2#Like' =
                #'Id' = '13'
            }

            Fields           = [ordered] @{
                "Computer"              = "Computer"
                'Date'                  = 'When'
                "MachineName"           = "ObjectAffected"
                "EventAction"           = "Action"
                #"NoNameB4"        = "EventLevel"
                "Message"               = "ActionDetails"
                "NoNameA1"              = "ActionDetailsDate"
                "NoNameA0"              = "ActionDetailsTime"
                "ActionDetailsDateTime" = "ActionDetailsDateTime"
                #"NoNameB7"        = "EventSource"
                "ID"                    = "Event ID"
                "RecordID"              = "Record ID"
                "GatheredFrom"          = "Gathered From"
                "GatheredLogName"       = "Gathered LogName"
            }

            Overwrite        = [ordered] @{
                "Action#1" = "Event ID", 12, "System Start"
                "Action#2" = "Event ID", 13, "System Shutdown"
                "Action#3" = "Event ID", 41, "System Dirty Reboot"
                "Action#4" = "Event ID", 4608, "Windows is starting up"
                "Action#5" = "Event ID", 4621, "Administrator recovered system from CrashOnAuditFail"
                "Action#6" = "Event ID", 6008, "System Crash"

            }
            OverwriteByField = @{
                # If StartTime -ne $null use StartTime in ActionDetailsDateTime
                'ActionDetailsDateTime#1#ne' = 'StartTime', $null, 'StartTime'
                'ActionDetailsDateTime#2#ne' = '#text', $null, '#text'
            }
        }
    }
    LdapBindingsDetails                 = $LdapBindingsDetails
    LdapBindingsSummary                 = $LdapBindingsSummary
}
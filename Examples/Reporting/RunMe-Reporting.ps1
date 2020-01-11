Import-Module "$PSScriptRoot\..\..\PSWinReportingV2.psd1" -Force

$Options = [ordered] @{
    JustTestPrerequisite = $false # runs testing without actually running script

    AsExcel              = @{
        Enabled     = $false # creates report in XLSX
        OpenAsFile  = $false

        Path        = 'C:\Support\Reports\ExportedEvents'
        FilePattern = 'Evotec-ADMonitoredEvents-<currentdate>.xlsx'
        DateFormat  = 'yyyy-MM-dd-HH_mm_ss'
    }
    AsCSV                = @{
        Enabled     = $false
        OpenAsFile  = $false

        Path        = 'C:\Support\Reports\ExportedEvents'
        FilePattern = 'Evotec-ADMonitoredEvents-<currentdate>-<reportname>.csv'
        DateFormat  = 'yyyy-MM-dd-HH_mm_ss'

        # Keep in mind <reportname> is critical here
        # if you don't use it next file will overwrite the old one
    }
    AsHTML               = @{
        Enabled     = $true # creates report in HTML
        OpenAsFile  = $true # requires AsHTML set to $true

        Path        = 'C:\Support\Reports\ExportedEvents'
        FilePattern = 'Evotec-ADMonitoredEvents-StaticHTML-<currentdate>.html'
        DateFormat  = 'yyyy-MM-dd-HH_mm_ss'

        Formatting  = @{
            CompanyBranding        = @{
                Logo   = 'https://evotec.xyz/wp-content/uploads/2015/05/Logo-evotec-012.png'
                Width  = '200'
                Height = ''
                Link   = 'https://evotec.xyz'
                Inline = $false
            }
            FontFamily             = 'Calibri Light'
            FontSize               = '9pt'
            FontHeadingFamily      = 'Calibri Light'
            FontHeadingSize        = '12pt'

            FontTableHeadingFamily = 'Calibri Light'
            FontTableHeadingSize   = '9pt'

            FontTableDataFamily    = 'Calibri Light'
            FontTableDataSize      = '9pt'

            Colors                 = @{
                # case sensitive
                Red   = 'removed', 'deleted', 'locked out', 'lockouts', 'disabled', 'Domain Admins', 'was cleared'
                Blue  = 'changed', 'changes', 'change', 'reset'
                Green = 'added', 'enabled', 'unlocked', 'created'
            }
            Styles                 = @{
                # case sensitive
                B = 'status', 'Domain Admins', 'Enterprise Admins', 'Schema Admins', 'was cleared', 'lockouts' # BOLD
                I = '' # Italian
                U = 'status'# Underline
            }
            Links                  = @{

            }
        }
    }
    AsDynamicHTML        = @{
        Enabled     = $true # creates report in Dynamic HTML
        OpenAsFile  = $true
        Title       = 'Windows Events'
        Path        = 'C:\Support\Reports\ExportedEvents'
        FilePattern = 'Evotec-ADMonitoredEvents-DynamicHTML-<currentdate>.html'
        DateFormat  = 'yyyy-MM-dd-HH_mm_ss'
        Branding    = @{
            Logo = @{
                Show      = $true
                RightLogo = @{
                    ImageLink = 'https://evotec.xyz/wp-content/uploads/2015/05/Logo-evotec-012.png'
                    Width     = '200'
                    Height    = ''
                    Link      = 'https://evotec.xyz'
                }
            }
        }
        EmbedCSS    = $false
        EmbedJS     = $false
    }
    AsSql                = @{
        Enabled               = $false
        SqlServer             = 'EVO1'
        SqlDatabase           = 'SSAE18'
        SqlTable              = 'dbo.[Events]'
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
    SendMail             = @{
        Enabled     = $false

        InlineHTML  = $true # this goes inline - if empty email will have no content

        Attach      = @{
            XLSX        = $true # this goes as attachment
            CSV         = $true # this goes as attachment
            DynamicHTML = $true # this goes as attachment
            HTML        = $true # this goes as attachment
            # if all 4 above are false email will have no attachment
            # remember that for this to work each part has to be enabled
            # using attach XLSX without generating XLSX won't magically let it attach
        }
        KeepReports = @{
            XLSX        = $true # keeps files after reports are sent
            CSV         = $true # keeps files after reports are sent
            HTML        = $true # keeps files after reports are sent
            DynamicHTML = $true # keeps files after reports are sent
        }
        Parameters  = @{
            From             = 'notifications@domain.pl'
            To               = 'przemyslaw.klys@domain.pl'
            CC               = ''
            BCC              = ''
            ReplyTo          = ''
            Server           = ''
            Password         = ''
            PasswordAsSecure = $false
            PasswordFromFile = $false
            Port             = '587'
            Login            = ''
            EnableSSL        = 1
            Encoding         = 'Unicode'
            Subject          = '[Reporting Evotec] Event Changes for period <<DateFrom>> to <<DateTo>>'
            Priority         = 'Low'
        }
    }
    RemoveDuplicates     = @{
        Enabled    = $true # when multiple sources are used it's normal for duplicates to occur. This cleans it up.
        Properties = 'RecordID', 'Computer'
    }
    Logging              = @{
        ShowTime   = $true
        LogsDir    = 'C:\temp\logs'
        TimeFormat = 'yyyy-MM-dd HH:mm:ss'
    }
    Debug                = @{
        DisplayTemplateHTML = $false
        Verbose             = $false
    }
}
$Target = [ordered]@{
    Servers           = [ordered] @{
        Enabled = $true
        # Server1 = @{ ComputerName = 'EVO1'; LogName = 'ForwardedEvents' }
        # Server2 = 'AD1', 'AD2'
        Server3 = 'AD1.ad.evotec.xyz'
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
## Define reports
$DefinitionsAD = [ordered] @{
    ADUserChanges                       = @{
        Enabled   = $true
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
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 5136, 5137, 5141
            LogName     = 'Security'
            Filter      = @{
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
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 5136, 5137, 5141
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
            IgnoreWords = @{}
        }
    }
    ADOrganizationalUnitChangesDetailed = [ordered] @{
        Enabled        = $true
        OUEventsModify = @{
            Enabled          = $true
            Events           = 5136, 5137, 5139, 5141
            LogName          = 'Security'
            Filter           = @{
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
            Overwrite        = @{
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
            OverwriteByField = @{
                'Organizational Unit' = 'Action', 'A directory service object was moved.', 'OldObjectDN'
                #'Field Changed'       = 'Action', 'A directory service object was moved.', ''
                'Field Value'         = 'Action', 'A directory service object was moved.', 'NewObjectDN'
            }
            SortBy           = 'Record ID'
            Descending       = $false
            IgnoreWords      = @{}
        }
    }
    ADUserStatus                        = @{
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 4722, 4725, 4767, 4723, 4724, 4726
            LogName     = 'Security'
            IgnoreWords = @{}
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
    ADUserLockouts                      = @{
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 4740
            LogName     = 'Security'
            IgnoreWords = @{}
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
    ADUserLogon                         = @{
        Enabled = $false
        Events  = @{
            Enabled     = $false
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
            IgnoreWords = @{}
        }
    }
    ADUserUnlocked                      = @{
        # 4767	A user account was unlocked
        # https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4767
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 4767
            LogName     = 'Security'
            IgnoreWords = @{}
            Functions   = @{}
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
    ADComputerCreatedChanged            = @{
        Enabled = $true
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
            IgnoreWords = @{}
        }
    }
    ADComputerDeleted                   = @{
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 4743 # deleted
            LogName     = 'Security'
            IgnoreWords = @{}
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
    ADUserLogonKerberos                 = @{
        Enabled = $false
        Events  = @{
            Enabled     = $false
            Events      = 4768
            LogName     = 'Security'
            IgnoreWords = @{}
            Functions   = @{
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
    ADGroupMembershipChanges            = @{
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 4728, 4729, 4732, 4733, 4746, 4747, 4751, 4752, 4756, 4757, 4761, 4762, 4785, 4786, 4787, 4788
            LogName     = 'Security'
            IgnoreWords = @{
                'Who' = '*ANONYMOUS*'
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
    ADGroupEnumeration                  = @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 4798, 4799
            LogName     = 'Security'
            IgnoreWords = @{
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
    ADGroupChanges                      = @{
        Enabled = $true
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
    ADGroupCreateDelete                 = @{
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 4727, 4730, 4731, 4734, 4744, 4748, 4749, 4753, 4754, 4758, 4759, 4763
            LogName     = 'Security'
            IgnoreWords = @{
                # 'Who' = '*ANONYMOUS*'
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
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 5136, 5137, 5141
            LogName     = 'Security'
            Filter      = @{
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
        Enabled                     = $true
        'Group Policy Name Changes' = @{
            Enabled     = $true
            Events      = 5136, 5137, 5141
            LogName     = 'Security'
            Filter      = @{
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
            Filter      = @{
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
    ADLogsClearedSecurity               = @{
        Enabled = $true
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
            IgnoreWords = @{}
            Overwrite   = @{
                # Allows to overwrite field content on the fly, either only on IF or IF ELSE
                # IF <VALUE> -eq <VALUE> THEN <VALUE> (3 VALUES)
                # IF <VALUE> -eq <VALUE> THEN <VALUE> ELSE <VALUE> (4 VALUES)
                # If you need to use IF multiple times for same field use spaces to distinguish HashTable Key.

                'Backup Path' = 'Backup Path', '', 'N/A'
                #'Backup Path ' = 'Backup Path', 'C:\Windows\System32\Winevt\Logs\Archive-Security-2018-11-24-09-25-36-988.evtx', 'MMMM'
                'Who'         = 'Event ID', 1105, 'Automatic Backup'  # if event id 1105 set field to Automatic Backup
                #'Test' = 'Event ID', 1106, 'Test', 'Mama mia'
            }
        }
    }
    ADLogsClearedOther                  = @{
        Enabled = $true
        Events  = @{
            Enabled     = $true
            Events      = 104
            LogName     = 'System'
            IgnoreWords = @{}
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
    ADEventsReboots                     = @{
        Enabled = $false
        Events  = @{
            Enabled     = $true
            Events      = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013
            LogName     = 'System'
            IgnoreWords = @{

            }
        }
    }
}

Start-WinReporting -Options $Options -Times $Times -Definitions $DefinitionsAD -Target $Target -Verbose
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
        Enabled     = $false # creates report in HTML
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


Start-WinReporting -Options $Options -Times $Times -Definitions $DefinitionsADSync -Target $Target -Verbose
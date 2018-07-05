Import-Module PSWinReporting -Force

Set-StrictMode -Version Latest
clear-host


$ReportDefinitions = @{
    TimeToGenerate = $false

    ReportsAD      = @{
        Servers    = @{
            Automatic = $true
            OnlyPDC   = $false
            DC        = ''
        }
        EventBased = @{
            UserChanges            = @{
                Enabled     = $true
                Events      = 4720, 4738
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserStatus             = @{
                Enabled     = $true
                Events      = 4722, 4725, 4767, 4723, 4724, 4726
                LogName     = 'Security'
                IgnoreWords = @{
                    'Domain Controller' = ''
                    'Action'            = ''
                    'User Affected'     = 'Win-*', '*AD1$*'
                    'Who'               = ''
                    'When'              = ''
                    'Event ID'          = ''
                    'Record ID'         = ''
                }
            }
            UserLockouts           = @{
                Enabled     = $true
                Events      = 4740
                LogName     = 'Security'
                IgnoreWords = ''
            }
            GroupMembershipChanges = @{
                Enabled     = $true
                Events      = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupCreateDelete      = @{
                Enabled     = $true
                Events      = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupPolicyChanges     = @{
                Enabled     = $true
                Events      = 5136, 5137, 5141
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedSecurity    = @{
                Enabled     = $true
                Events      = 1102
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedOther       = @{
                Enabled     = $true
                Events      = 104
                LogName     = 'System'
                IgnoreWords = ''
            }
        }
        Custom     = @{
            EventLogSize = @{
                Enabled = $true
                Logs    = 'Security', 'Application', 'System'
                SortBy  = ''
            }
            ServersData  = @{
                Enabled = $true
            }
        }
    }
}

$Events = Get-EventsData -ReportDefinitions $ReportDefinitions -LogName 'Security'
$Systems = Get-EventsData -ReportDefinitions $ReportDefinitions -LogName 'System'

$DomainControllers = (Get-ADDomainController -Filter * | Select HostName).HostName

$xmlTemplate = "$PSScriptRoot\..\Forwarders\Template.xml"


if (Test-Path $xmlTemplate) {
    $Array = New-ArrayList
    $SplitArrayID = Split-Array -inArray $Events -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
    foreach ($ID in $SplitArrayID) {
        Add-ToArray -List $Array -Element (New-EventQuery -Events $ID -Type 'Security')
    }
    Add-ToArray -List $Array -Element (New-EventQuery -Events $Systems -Type 'System')
    $i = 0
    foreach ($Events in $Array) {
        $i++
        $SubscriptionTemplate = "$ENV:TEMP\MyTemplate$i.xml"
        Copy-Item -Path $xmlTemplate $SubscriptionTemplate

        Add-ServersToXML -FilePath $SubscriptionTemplate -Servers $DomainControllers

        Set-XML -FilePath $SubscriptionTemplate -Node 'SubscriptionId' -Value "PSWinReporting Subscription Events - $i"
        Set-XML -FilePath $SubscriptionTemplate -Node 'ContentFormat' -Value 'Events'
        Set-XML -FilePath $SubscriptionTemplate -Node 'ConfigurationMode' -Value 'Custom'
        $Events
        Set-XML -FilePath $SubscriptionTemplate -Node 'Query' -Value $Events
    }
}


Start-MyProgram -Program $ProgramWecutil -cmdArgList 'cs', "$ENV:TEMP\MyTemplate1.xml"
Start-MyProgram -Program $ProgramWecutil -cmdArgList 'cs', "$ENV:TEMP\MyTemplate2.xml"
Start-MyProgram -Program $ProgramWecutil -cmdArgList 'cs', "$ENV:TEMP\MyTemplate3.xml"

#>

#<Select Path="Security">*[System[(EventID=11 or EventID=11 or EventID=23)]]</Select>
#<Select Path="System">*[System[(EventID=11 or EventID=11 or EventID=23)]]</Select>


#$Subscription = 'User Changes (4720, 4738)'
#wecutil gr $Subscription
#wecutil gs $Subscription /f:xml > test.xml


#wecutil.exe cs '.\Forwarders\PSWinReporting1.xml'
#wecutil.exe cs '.\Forwarders\PSWinReporting2.xml'
#wecutil.exe cs '.\Forwarders\PSWinReporting3.xml'


#Start-MyProgram -Program $ProgramWecutil -cmdArgList 'cs', $xml
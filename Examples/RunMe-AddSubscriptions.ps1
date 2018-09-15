Clear-Host
Import-Module PSWinReporting -Force
Import-Module PSSharedGoods -Force

$ReportDefinitions = @{
    ReportsAD = @{
        Servers    = @{
            Automatic = $true
            OnlyPDC   = $false
            DC        = ''
        }
        EventBased = @{
            UserChanges            = @{
                Enabled = $true
                Events  = 4720, 4738
                LogName = 'Security'
            }
            UserStatus             = @{
                Enabled = $true
                Events  = 4722, 4725, 4767, 4723, 4724, 4726
                LogName = 'Security'
            }
            ComputerCreatedChanged = @{
                Enabled     = $true
                Events      = 4741, 4742 # created, changed
                LogName     = 'Security'
                IgnoreWords = ''
            }
            ComputerDeleted        = @{
                Enabled     = $true
                Events      = 4743 # deleted
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserLockouts           = @{
                Enabled = $true
                Events  = 4740
                LogName = 'Security'
            }
            GroupMembershipChanges = @{
                Enabled = $true
                Events  = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                LogName = 'Security'
            }
            GroupCreateDelete      = @{
                Enabled = $true
                Events  = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName = 'Security'
            }
            GroupPolicyChanges     = @{
                Enabled = $true
                Events  = 5136, 5137, 5141
                LogName = 'Security'
            }
            LogsClearedSecurity    = @{
                Enabled = $true
                Events  = 1102, 1105
                LogName = 'Security'
            }
            LogsClearedOther       = @{
                Enabled = $true
                Events  = 104
                LogName = 'System'
            }
        }
    }
}

Start-SubscriptionService
$Providers = New-SubscriptionTemplates -ReportDefinitions $ReportDefinitions -Verbose
Set-SubscriptionTemplates -ListTemplates $Providers -DeleteOwn
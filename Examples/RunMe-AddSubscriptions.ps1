Clear-Host
Import-Module PSWinReporting -Force

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
                Events  = 1102
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

$Providers = New-SubscriptionTemplates -ReportDefinitions $ReportDefinitions
Set-SubscriptionTemplates -ListTemplates $Providers -DeleteOwn
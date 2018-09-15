$Script:ProgramWecutil = "wecutil.exe"
$Script:ProgramWevtutil = 'wevtutil.exe'
$script:WriteParameters = @{
    ShowTime   = $true
    LogFile    = ""
    TimeFormat = "yyyy-MM-dd HH:mm:ss"
}
$script:TimeToGenerateReports = [ordered]@{
    Reports = [ordered] @{
        UserChanges            = @{
            Total = $null
        }
        UserStatus             = @{
            Total = $null
        }
        UserLockouts           = @{
            Total = $null
        }
        UserLogon              = @{
            Total = $null
        }
        UserLogonKerberos      = @{
            Total = $null
        }
        GroupMembershipChanges = @{
            Total = $null
        }
        GroupCreateDelete      = @{
            Total = $null
        }
        GroupPolicyChanges     = @{
            Total = $null
        }
        LogsClearedSecurity    = @{
            Total = $null
        }
        LogsClearedOther       = @{
            Total = $null
        }
        EventsReboots          = @{
            Total = $null
        }
        EventLogSize           = @{
            Total = $null
        }
        ServersData            = @{
            Total = $null
        }
        ComputerCreatedChanged = @{
            Total = $null
        }
        ComputerDeleted        = @{
            Total = $null
        }
    }
}

Import-Module "$PSScriptRoot\..\..\PSWinReportingV2.psd1" -Force

# This is required if script is not run as admin. It will open up this script as Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$Target = [ordered]@{
    Servers           = [ordered] @{
        Enabled = $false
        # Server1 = @{ ComputerName = 'EVO1'; LogName = 'ForwardedEvents' }
        #Server2 = 'AD1', 'AD2'
        Server3 = 'AD1.ad.evotec.xyz', 'AD2'
    }
    DomainControllers = [ordered] @{
        Enabled = $true
    }
}

$Reports = 'ADGroupPolicyChanges'

Start-WinSubscriptionService
New-WinSubscriptionTemplates -Target $Target -AddTemplates -Reports $Reports
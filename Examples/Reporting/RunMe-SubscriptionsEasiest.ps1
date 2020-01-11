Import-Module "$PSScriptRoot\..\..\PSWinReportingV2.psd1" -Force

# This is required if script is not run as admin. It will open up this script as Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Targets Forest and all domains (all DC's)
# You can exclude / include domains/dcs with parameters

Start-WinSubscriptionService
New-WinSubscriptionTemplates -AddTemplates
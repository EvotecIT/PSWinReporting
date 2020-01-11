Import-Module "$PSScriptRoot\..\..\PSWinReportingV2.psd1" -Force

# This is required if script is not run as admin. It will open up this script as Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Targets Forest and all domains (all DC's)
# You can exclude / include domains/dcs with parameters

$Reports = @(
    'ADComputerChangesDetailed'
    'ADGroupChanges'
    'ADGroupEnumeration'
    'ADLogsClearedOther'
    'ADUserChanges'
    'ADUserUnlocked'
    'OSStartupShutdownCrash'
    'ADComputerCreatedChanged'
    'ADGroupChangesDetailed'
    'ADGroupMembershipChanges'
    'ADLogsClearedSecurity'
    'ADUserChangesDetailed'
    'NetworkAccessAuthenticationPolicy'
    'ADComputerDeleted'
    'ADGroupCreateDelete'
    'ADGroupPolicyChanges'
    'ADOrganizationalUnitChangesDetailed'
    'ADUserLockouts'
    'ADUserStatus'
    'OSCrash'
    #'ADUserLogon'
    #'ADUserLogonKerberos'
)

Start-WinSubscriptionService
New-WinSubscriptionTemplates -AddTemplates -Reports $Reports
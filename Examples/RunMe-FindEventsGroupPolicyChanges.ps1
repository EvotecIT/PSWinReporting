Import-Module .\PSWinReportingV2.psd1 -Force

$Events = Find-Events -Report ADGroupPolicyChanges,ADOrganizationalUnitChangesDetailed -DatesRange CurrentDay -Servers 'AD1' -Verbose
$Events | Format-Table -AutoSize
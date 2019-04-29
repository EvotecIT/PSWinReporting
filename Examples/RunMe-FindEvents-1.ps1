Import-Module .\PSWinReportingV2.psd1 -Force

$Events = Find-Events -Report ADUserLogon -DatesRange PastHour -Servers 'AD1' -Verbose
$Events | Format-Table -AutoSize

$Events = Find-Events -Report ADGroupMembershipChanges -DatesRange PastHour -Servers 'AD1' -Verbose
$Events | Format-Table -AutoSize

$Events = Find-Events -Report ADGroupMembershipChanges -DatesRange Last3days -Servers 'AD1', 'AD2' -Who 'przemyslaw.klys' -Verbose
$Events | Format-Table -AutoSize

$Events = Find-Events -Report ADGroupMembershipChanges -DatesRange PastDay -Servers 'AD1', 'AD2' -Whom 'Domain Admins' -Verbose
$Events | Format-Table -AutoSize
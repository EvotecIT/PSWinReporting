Import-Module .\..\PsWinReporting.psd1 -Force
Import-Module PSEventViewer -Force
Import-Module PSSharedGoods -Force

$Events = Find-Events -Report GroupMembershipChanges -DatesRange PastMonth -Servers AD1,AD2 -Verbose
$Events | Format-Table -AutoSize
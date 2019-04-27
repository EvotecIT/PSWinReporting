Import-Module .\PSWinReportingV2.psd1 -Force

$Events = Find-Events -Report ADUserChanges -DatesRange Last14days -Servers 'AD1', 'AD2' -Verbose
$Events | Format-Table -AutoSize
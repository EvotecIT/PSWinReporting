Import-Module .\PSWinReportingV2.psd1 -Force

if ($null -eq $Credentials) {
    $Credentials = Get-Credential
}

#$Events = Find-Events -Report ADUserLogon -DatesRange PastHour -Servers 'AD1' -Verbose
#$Events | Format-Table -AutoSize

$DateStart = (Get-Date).AddDays(-2)
$DateEnd = Get-Date

$Events = Find-Events -Report ADGroupMembershipChanges -Servers 'AD1' -DateFrom $DateStart -DateTo $DateEnd #-Verbose
$Events | Format-Table -AutoSize

$Events = Find-Events -Report ADGroupMembershipChanges -Servers 'AD1' -DateFrom $DateStart -DateTo $DateEnd -Credential $Credentials #-Verbose
$Events | Format-Table -AutoSize
Import-Module .\PSWinReporting.psd1 -Force
#Import-Module PSEventViewer -Force
#Import-Module PSSharedGoods -Force

$Events = Find-Events -Report GroupChanges, GroupChangesDetailed -DatesRange Last7Days -Servers 'AD1','AD2' #-DetectDC
$Events | Format-Table -AutoSize
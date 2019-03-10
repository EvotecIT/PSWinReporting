Import-Module .\..\PsWinReporting.psd1 -Force
#Import-Module PSEventViewer -Force
#Import-Module PSSharedGoods -Force

$Events = Find-Events -Report  -DatesRange  -DetectDC
$Events | Format-Table -AutoSize
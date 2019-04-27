Import-Module .\PSWinReportingV2.psd1 -Force
#Import-Module PSEventViewer -Force
#Import-Module PSSharedGoods -Force

Find-Events -Report ADUserChanges -DatesRange Last14days -Servers 'AD1','AD2' -Verbose
#$Events | Format-Table -AutoSize
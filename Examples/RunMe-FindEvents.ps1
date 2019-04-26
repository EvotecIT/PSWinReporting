Import-Module .\PSWinReporting.psd1 -Force
#Import-Module PSEventViewer -Force
#Import-Module PSSharedGoods -Force

Find-Events -Report UserChanges -DatesRange Last14days -Servers 'AD1','AD2' -Verbose
#$Events | Format-Table -AutoSize
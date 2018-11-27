Import-Module PSWinReporting -Force
Import-Module PSSharedGoods -Force

Find-ADEvents -Report UserStatus -DatesRange CurrentDay | Format-Table -AutoSize
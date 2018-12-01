Import-Module PSWinReporting -Force
Import-Module PSSharedGoods -Force

$Events = Find-ADEvents -Report EventsReboots -DatesRange CurrentDay -Server AD1, AD2
$Events | Format-Table -Property *
#$Events[0] | Format-List -Property *
#Import-Module .\..\PsWinReporting.psd1 -Force
Import-Module PSWinReporting -Force
Import-Module PSSharedGoods #-Force

$Events = Find-ADEvents -Report GroupPolicyChanges -DatesRange CurrentMonth -Server AD1, AD2
$Events | Format-Table -Property *
$Events | Out-GridView
Import-Module PSWinReporting -Force
Import-Module PSSharedGoods #-Force

$Events = Find-ADEvents -Report GroupPolicyChanges -DatesRange CurrentDay -Server AD1, AD2
$Events | Format-Table -Property *
#$Events[0] | Format-List -Property *
#$Events | Where { $_.AuthenticationPackageName -eq 'NTLM' }



#$Events[0] | Format-List -Property *
#$Events[1] | Format-List -Property *
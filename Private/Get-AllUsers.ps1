function Get-AllUsers($domain) {
    $Users = Get-ADUser -Filter { EmailAddress -like "*@$domain" } -Properties DisplayName, SamAccountName, Enabled, Mail, EmailAddress, UserPrincipalName, mailnickname, proxyAddresses #| Where { $_.EmailAddress -like "*@colmore.com" }
    $UsersWithWrongMailNickName = $Users | Where { $_.MailNickName -eq $null - $_.MailNickName -eq '' } | Select-Object DisplayName, SamAccountName, Enabled, EmailAddress, UserPrincipalName, mailnickname
    $UsersWithProxy = $users | Select-Object DisplayName, SamAccountName, Enabled, EmailAddress, UserPrincipalName, proxyAddresses
    foreach ($user in $UsersWithProxy) {
        $user | Add-member -NotePropertyName "ProxyStatus" -NotePropertyValue $proxyStatus
    }
}
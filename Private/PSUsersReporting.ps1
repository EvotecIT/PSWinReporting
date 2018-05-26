function Find-UsersProxyAddressesStatus ($User) {
    $status = 'No proxy'
    if ($user.proxyAddresses -ne $null) {
        $count = 0
        foreach ($proxy in $($user.ProxyAddresses)) {
            if ($proxy.SubString(0, 4) -ceq 'SMTP') { $count++ }
        }
        if ($count -eq 0) {
            $status = 'Missing primary proxy'
        } elseif ($count -gt 1) {
            $status = 'Multiple primary proxy'
        } else {
            $status = 'All OK'
        }
    } else {
        $status = 'Missing all proxy'
    }
    return $status
}


function Get-AllUsers($domain) {
    $Users = Get-ADUser -Filter { EmailAddress -like "*@$domain" } -Properties DisplayName, SamAccountName, Enabled, Mail, EmailAddress, UserPrincipalName, mailnickname, proxyAddresses #| Where { $_.EmailAddress -like "*@colmore.com" }
    $UsersWithWrongMailNickName = $Users | Where { $_.MailNickName -eq $null - $_.MailNickName -eq '' } | Select-Object DisplayName, SamAccountName, Enabled, EmailAddress, UserPrincipalName, mailnickname
    $UsersWithProxy = $users | Select-Object DisplayName, SamAccountName, Enabled, EmailAddress, UserPrincipalName, proxyAddresses
    foreach ($user in $UsersWithProxy) {
        $user | Add-member -NotePropertyName "ProxyStatus" -NotePropertyValue $proxyStatus
    }
}

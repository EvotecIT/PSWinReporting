Function Convert-UAC ([int]$UAC) {
    $PropertyFlags = @(s
        "SCRIPT",
        "ACCOUNTDISABLE",
        "RESERVED",
        "HOMEDIR_REQUIRED",
        "LOCKOUT",
        "PASSWD_NOTREQD",
        "PASSWD_CANT_CHANGE",
        "ENCRYPTED_TEXT_PWD_ALLOWED",
        "TEMP_DUPLICATE_ACCOUNT",
        "NORMAL_ACCOUNT",
        "RESERVED",
        "INTERDOMAIN_TRUST_ACCOUNT",
        "WORKSTATION_TRUST_ACCOUNT",
        "SERVER_TRUST_ACCOUNT",
        "RESERVED",
        "RESERVED",
        "DONT_EXPIRE_PASSWORD",
        "MNS_LOGON_ACCOUNT",
        "SMARTCARD_REQUIRED",
        "TRUSTED_FOR_DELEGATION",
        "NOT_DELEGATED",
        "USE_DES_KEY_ONLY",
        "DONT_REQ_PREAUTH",
        "PASSWORD_EXPIRED",
        "TRUSTED_TO_AUTH_FOR_DELEGATION",
        "RESERVED",
        "PARTIAL_SECRETS_ACCOUNT"
        "RESERVED"
        "RESERVED"
        "RESERVED"
        "RESERVED"
        "RESERVED"
    )
    #Possibility 1: One property per line (commented because I use the second one)
    #1..($PropertyFlags.Length) | Where-Object {$UAC -bAnd [math]::Pow(2,$_)} | ForEach-Object {$PropertyFlags[$_]}

    #Possibility 2: One line for all properties (suits my script better)
    $Attributes = ""
    1..($PropertyFlags.Length) | Where-Object {$UAC -bAnd [math]::Pow(2, $_)} | ForEach-Object {If ($Attributes.Length -EQ 0) {$Attributes = $PropertyFlags[$_]} Else {$Attributes = $Attributes + ", " + $PropertyFlags[$_]}}
    Return $Attributes
}
function ConvertFrom-SID ($Sid) {
    $KnownSIDs = @{
        'S-1-0' = 'Null Authority'
        'S-1-0-0' = 'Nobody'
        'S-1-1' = 'World Authority'
        'S-1-1-0' = 'Everyone'
        'S-1-2' = 'Local Authority'
        'S-1-2-0' = 'Local'
        'S-1-2-1' = 'Console Logon'
        'S-1-3' = 'Creator Authority'
        'S-1-3-0' = 'Creator Owner'
        'S-1-3-1' = 'Creator Group'
        'S-1-3-2' = 'Creator Owner Server'
        'S-1-3-3' = 'Creator Group Server'
        'S-1-3-4' = 'Owner Rights'
        'S-1-5-80-0' = 'All Services'
        'S-1-4' = 'Non-unique Authority'
        'S-1-5' = 'NT Authority'
        'S-1-5-1' = 'Dialup'
        'S-1-5-2' = 'Network'
        'S-1-5-3' = 'Batch'
        'S-1-5-4' = 'Interactive'
        'S-1-5-6' = 'Service'
        'S-1-5-7' = 'Anonymous'
        'S-1-5-8' = 'Proxy'
        'S-1-5-9' = 'Enterprise Domain Controllers'
        'S-1-5-10' = 'Principal Self'
        'S-1-5-11' = 'Authenticated Users'
        'S-1-5-12' = 'Restricted Code'
        'S-1-5-13' = 'Terminal Server Users'
        'S-1-5-14' = 'Remote Interactive Logon'
        'S-1-5-15' = 'This Organization'
        'S-1-5-17' = 'This Organization'
        'S-1-5-18' = 'Local System'
        'S-1-5-19' = 'NT Authority'
        'S-1-5-20' = 'NT Authority'
        'S-1-5-32-544' = 'Administrators'
        'S-1-5-32-545' = 'Users'
        'S-1-5-32-546' = 'Guests'
        'S-1-5-32-547' = 'Power Users'
        'S-1-5-32-548' = 'Account Operators'
        'S-1-5-32-549' = 'Server Operators'
        'S-1-5-32-550' = 'Print Operators'
        'S-1-5-32-551' = 'Backup Operators'
        'S-1-5-32-552' = 'Replicators'
        'S-1-5-64-10' = 'NTLM Authentication'
        'S-1-5-64-14' = 'SChannel Authentication'
        'S-1-5-64-21' = 'Digest Authority'
        'S-1-5-80' = 'NT Service'
        'S-1-5-83-0' = 'NT VIRTUAL MACHINE\Virtual Machines'
        'S-1-16-0' = 'Untrusted Mandatory Level'
        'S-1-16-4096' = 'Low Mandatory Level'
        'S-1-16-8192' = 'Medium Mandatory Level'
        'S-1-16-8448' = 'Medium Plus Mandatory Level'
        'S-1-16-12288' = 'High Mandatory Level'
        'S-1-16-16384' = 'System Mandatory Level'
        'S-1-16-20480' = 'Protected Process Mandatory Level'
        'S-1-16-28672' = 'Secure Process Mandatory Level'
        'S-1-5-32-554' = 'BUILTIN\Pre-Windows 2000 Compatible Access'
        'S-1-5-32-555' = 'BUILTIN\Remote Desktop Users'
        'S-1-5-32-556' = 'BUILTIN\Network Configuration Operators'
        'S-1-5-32-557' = 'BUILTIN\Incoming Forest Trust Builders'
        'S-1-5-32-558' = 'BUILTIN\Performance Monitor Users'
        'S-1-5-32-559' = 'BUILTIN\Performance Log Users'
        'S-1-5-32-560' = 'BUILTIN\Windows Authorization Access Group'
        'S-1-5-32-561' = 'BUILTIN\Terminal Server License Servers'
        'S-1-5-32-562' = 'BUILTIN\Distributed COM Users'
        'S-1-5-32-569' = 'BUILTIN\Cryptographic Operators'
        'S-1-5-32-573' = 'BUILTIN\Event Log Readers'
        'S-1-5-32-574' = 'BUILTIN\Certificate Service DCOM Access'
        'S-1-5-32-575' = 'BUILTIN\RDS Remote Access Servers'
        'S-1-5-32-576' = 'BUILTIN\RDS Endpoint Servers'
        'S-1-5-32-577' = 'BUILTIN\RDS Management Servers'
        'S-1-5-32-578' = 'BUILTIN\Hyper-V Administrators'
        'S-1-5-32-579' = 'BUILTIN\Access Control Assistance Operators'
        'S-1-5-32-580' = 'BUILTIN\Remote Management Users'
    }
    foreach ($id in $sid) {
        if ($name = $KnownSIDs[$id]) { }
        else {
            #Try to translate the SID to an account
            Try {
                $objSID = New-Object System.Security.Principal.SecurityIdentifier($id)
                $name = ( $objSID.Translate([System.Security.Principal.NTAccount]) ).Value
            } Catch {
                $name = $sid # returns sid if unable to name
            }
        }
        return @{ SID = $id
            Name = $name
        }

    }

}

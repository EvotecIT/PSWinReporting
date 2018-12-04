function Set-ServersPermissions {
    [CmdletBinding()]
    param (
        $ProgramWevtutil,
        $Servers,
        [string]$LogName = 'security'
    )


    foreach ($DC in $Servers) {
        $cmdArgListGet = @(
            "gl"
            $LogName
            "/r:$DC"
        )
        $cmdArgListSet = @(
            "sl",
            $LogName
            "/r:$DC"
            "/ca:O:BAG:SYD:(A; ; 0xf0005; ; ; SY)(A; ; 0x5; ; ; BA)(A; ; 0x1; ; ; S-1-5-32-573)(A; ; 0x1; ; ; S-1-5-20)"
        )

        Start-MyProgram -Program $Script:ProgramWevtutil -cmdArgList $cmdArgListSet
        Start-MyProgram -Program $Script:ProgramWevtutil -cmdArgList $cmdArgListGet
    }
}
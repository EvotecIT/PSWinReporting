function Get-ServersPermissions {
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
        Start-MyProgram -Program $Script:ProgramWevtutil -cmdArgList $cmdArgListGet
    }
}
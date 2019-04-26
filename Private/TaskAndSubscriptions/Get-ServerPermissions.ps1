function Get-ServersPermissions {
    [CmdletBinding()]
    param (
        [string] $ProgramWevtutil,
        [string[]] $Servers,
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
function New-TargetServers {
    [CmdLetBinding()]
    param(
        [string[]] $Servers,
        [switch] $UseDC
    )
    $Target = [ordered]@{
        Servers           = [ordered] @{
            Enabled = if ($Servers -and ($UseDC -eq $false)) { $true } else { $false }
            Servers = $Servers
        }
        DomainControllers = [ordered] @{
            Enabled = $UseDC
        }
        LocalFiles        = [ordered] @{
            Enabled     = $false
            Directories = [ordered] @{}
            Files       = [ordered] @{}
        }
    }
    return $Target
}
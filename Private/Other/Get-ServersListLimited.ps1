function Get-ServersListLimited {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Target,
        [int64] $RecordID
    )
    $ServersList = New-ArrayList
    if ($Target.Servers.Enabled) {
        $Logger.AddInfoRecord("Preparing servers list - defined list")
        [Array] $Servers = foreach ($Server in $Target.Servers.Keys | Where-Object { $_ -ne 'Enabled' }) {

            if ($Target.Servers.$Server -is [System.Collections.IDictionary]) {
                [ordered] @{
                    ComputerName = $Target.Servers.$Server.ComputerName
                    LogName      = $Target.Servers.$Server.LogName
                }

            } elseif ($Target.Servers.$Server -is [Array] -or $Target.Servers.$Server -is [string]) {
                $Target.Servers.$Server
            }
        }
        $null = $ServersList.AddRange($Servers)
    }
    [Array] $ExtendedInput = foreach ($Server in $ServersList) {
        [PSCustomObject] @{
            Server   = $Server.ComputerName
            LogName  = $Server.LogName
            RecordID = $RecordID
        }
    }
    , $ExtendedInput
}
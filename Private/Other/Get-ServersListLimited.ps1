function Get-ServersListLimited {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Target,
        [int64] $RecordID,
        [switch] $Quiet,
        [string] $Who,
        [string] $Whom,
        [string] $NotWho,
        [string] $NotWhom
    )
    if ($Target.Servers.Enabled) {
        if (-not $Quiet) { $Logger.AddInfoRecord("Preparing servers list - defined list") }
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
    }
    [Array] $ExtendedInput = foreach ($Server in $Servers) {
        [PSCustomObject] @{
            Server                 = $Server.ComputerName
            LogName                = $Server.LogName
            RecordID               = $RecordID
            NamedDataFilter        = if ($NamedDataFilter.Count -ne 0) { $NamedDataFilter } else { }
            NamedDataExcludeFilter = if ($NamedDataExcludeFilter.Count -ne 0) { $NamedDataExcludeFilter } else { }
        }
    }
    if ($ExtendedInput.Count -gt 1) {
        $ExtendedInput

    } else {
        , $ExtendedInput
    }
}
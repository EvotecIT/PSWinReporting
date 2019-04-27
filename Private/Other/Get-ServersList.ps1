function Get-ServersList {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Definitions,
        [System.Collections.IDictionary] $Target,
        [System.Collections.IDictionary] $Dates
    )
    # Get Servers
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
    if ($Target.DomainControllers.Enabled) {
        $Logger.AddInfoRecord("Preparing servers list - domain controllers autodetection")
        [Array] $Servers = (Get-WinADDomainControllers -SkipEmpty).HostName
        $null = $ServersList.AddRange($Servers)
    }
    if ($Target.LocalFiles.Enabled) {
        $Logger.AddInfoRecord("Preparing file list - defined event log files")
        $Files = Get-EventLogFileList -Sections $Target.LocalFiles
    }
    # Prepare list of servers and files to scan and their relation to LogName and EventIDs and DataTimes
    <#
        Server                                                    LogName         EventID                     Type
        ------                                                    -------         -------                     ----
        AD1                                                       Security        {5136, 5137, 5141, 5136...} Computer
        AD2                                                       Security        {5136, 5137, 5141, 5136...} Computer
        EVO1                                                      ForwardedEvents {5136, 5137, 5141, 5136...} Computer
        AD1.ad.evotec.xyz                                         Security        {5136, 5137, 5141, 5136...} Computer
        AD2.ad.evotec.xyz                                         Security        {5136, 5137, 5141, 5136...} Computer
        C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx Security        {5136, 5137, 5141, 5136...} File
        C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx Security        {5136, 5137, 5141, 5136...} File
        C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx Security        {5136, 5137, 5141, 5136...} File
        C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx Security        {5136, 5137, 5141, 5136...} File
        AD1                                                       System          104                         Computer
        AD2                                                       System          104                         Computer
        EVO1                                                      ForwardedEvents 104                         Computer
        AD1.ad.evotec.xyz                                         System          104                         Computer
        AD2.ad.evotec.xyz                                         System          104                         Computer
        C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx System          104                         File
        C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx System          104                         File
        C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx System          104                         File
        C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx System          104                         File
    #>

    # Get LogNames
    [Array] $LogNames = foreach ($Report in  $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport'}) {
        if ($Definitions.$Report.Enabled) {
            foreach ($SubReport in $Definitions.$Report.Keys | Where-Object { $_ -notcontains 'Enabled' }) {
                if ($Definitions.$Report.$SubReport.Enabled) {
                    $Definitions.$Report.$SubReport.LogName
                }
            }
        }
    }
    [Array] $ExtendedInput = foreach ($Log in $LogNames | Sort-Object -Unique) {
        $EventIDs = foreach ($Report in  $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport'}) {
            if ($Definitions.$Report.Enabled) {
                foreach ($SubReport in $Definitions.$Report.Keys | Where-Object { $_ -notcontains 'Enabled' }) {
                    if ($Definitions.$Report.$SubReport.Enabled) {
                        if ($Definitions.$Report.$SubReport.LogName -eq $Log) {
                            $Definitions.$Report.$SubReport.Events
                        }
                    }
                }
            }
        }
        #$Logger.AddInfoRecord("Preparing to scan log $Log for Events:$($EventIDs -join ', ')")

        $OutputServers = foreach ($Server in $ServersList) {
            if ($Server -is [System.Collections.IDictionary]) {
                [PSCustomObject]@{
                    Server   = $Server.ComputerName
                    LogName  = $Server.LogName
                    EventID  = $EventIDs | Sort-Object -Unique
                    Type     = 'Computer'
                    DateFrom = $Dates.DateFrom
                    DateTo   = $Dates.DateTo
                }
            } elseif ($Server -is [Array] -or $Server -is [string]) {
                foreach ($S in $Server) {
                    [PSCustomObject]@{
                        Server   = $S
                        LogName  = $Log
                        EventID  = $EventIDs | Sort-Object -Unique
                        Type     = 'Computer'
                        DateFrom = $Dates.DateFrom
                        DateTo   = $Dates.DateTo
                    }
                }
            }
        }
        $OutputFiles = foreach ($File in $FIles) {
            [PSCustomObject]@{
                Server   = $File
                LogName  = $Log
                EventID  = $EventIDs | Sort-Object -Unique
                Type     = 'File'
                DateFrom = $Dates.DateFrom
                DateTo   = $Dates.DateTo
            }
        }
        $OutputServers
        $OutputFiles
    }
    , $ExtendedInput
}
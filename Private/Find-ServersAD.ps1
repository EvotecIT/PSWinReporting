function Find-ServersAD {
    param (
        $DC,
        $ReportDefinitions
    )
    $Servers = @()

    # Cleans up empty HostName for failed domain
    $DC = $DC | Where-Object { $_.'Host Name' -ne '' }


    if ($ReportDefinitions.ReportsAD.Servers.Automatic -eq $true) {
        if ($ReportDefinitions.ReportsAD.Servers.OnlyPDC -eq $true) {
            $Servers += ($DC | Where-Object { $_.'Is PDC' -eq 'Yes' }).'Host Name'
        } else {
            $Servers += $DC.'Host Name'
        }
    } else {
        if ($ReportDefinitions.ReportsAD.Servers.DC -eq '' -and $ReportDefinitions.ReportsAD.Servers.UseForwarders -eq $false) {
            $Logger.AddErrorRecord("Parameter ReportDefinitions.ReportsAD.Servers.DC is empty. Please choose Automatic or fill in this field")
            exit
        } else {
            $Servers += $ReportDefinitions.ReportsAD.Servers.DC
        }
    }
    #}
    return $Servers
}
function Find-ServersAD {
    param (
        $DC,
        $ReportDefinitions
    )
    if ($ReportDefinitions.ReportsAD.Servers.Automatic -eq $true) {
        if ($ReportDefinitions.ReportsAD.Servers.OnlyPDC -eq $true) {
            $Servers = ($DC | Where { $_.'Is PDC' -eq 'Yes' }).'Host Name'
        } else {
            $Servers = $DC.'Host Name'
        }
    } else {
        if ($ReportDefinitions.ReportsAD.Servers.DC -eq '' -and $ReportDefinitions.ReportsAD.Servers.UseForwarders -eq $false) {
            Write-Color @script:WriteParameters "[i] Error: ", "Parameter ", 'ReportDefinitions.ReportsAD.Servers.DC', ' is empty. Please choose ', 'Automatic', ' or fill in this field.' -Color White, White, Yellow, White, Yellow, White
            Exit
        } else {
            $Servers = $ReportDefinitions.ReportsAD.Servers.DC
        }
    }
    return $Servers
}
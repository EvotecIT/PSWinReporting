function Get-DomainControllers($Servers) {
    $DomainControllers = @()
    try {
        $DomainControllers = Get-ADDomainController -Filter * | Select-Object Name , HostName, Ipv4Address, IsGlobalCatalog, IsReadOnly, OperatingSystem, Site, Enabled #, Supported, Reporting #,
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        switch ($ErrorMessage) {
            {$_ -match 'The server has rejected the client credentials'} {
                $Logger.AddErrorRecord("Domain Controller has rejected the client credentials. Please run this script with access to Domain Controllers")
            }
            {$_ -match 'Unable to find a default server with Active Directory Web Services running' } {
                $Logger.AddErrorRecord("Active Directory not found. Please run this script with access to server with Active Directory Web Services running")
            }
            default {
                $Logger.AddErrorRecord("Error: $ErrorMessage")
            }
        }
        exit
    }
    foreach ($DC in $DomainControllers) {
        Add-Member -InputObject $DC -MemberType NoteProperty -Name "Supported" -Value "Yes"
        Add-Member -InputObject $DC -MemberType NoteProperty -Name "Reporting" -Value "Yes"
        if ($DC.OperatingSystem -like "*2003*" -or $DC.OperatingSystem -like "*2000*") {
            $DC.Supported = "No"
        }
        foreach ($S in $Servers) {
            if ($S -eq $DC.Hostname -or $S -eq $DC.Name) {
                $DC.Reporting = $true
            }
        }
    }
    return $DomainControllers
}

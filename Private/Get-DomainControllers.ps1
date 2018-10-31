function Get-DomainControllers($Servers) {
    $DomainControllers = @()
    try {
        $DomainControllers = Get-ADDomainController -Filter * | Select-Object Name , HostName, Ipv4Address, IsGlobalCatalog, IsReadOnly, OperatingSystem, Site, Enabled #, Supported, Reporting #,
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        switch ($ErrorMessage) {
            {$_ -match 'The server has rejected the client credentials'} { 
                Write-Color @script:WriteParameters "[-] ", "Domain Controller", " has rejected the client credentials. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
            }
            {$_ -match 'Unable to find a default server with Active Directory Web Services running' } {
                Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
            }
        }
        Write-Color @script:WriteParameters "[i] Error: ", $ErrorMessage -Color White, Red
        exit
    }
    foreach ($dc in $DomainControllers) {
        Add-Member -InputObject $dc -MemberType NoteProperty -Name "Supported" -Value "Yes"
        Add-Member -InputObject $dc -MemberType NoteProperty -Name "Reporting" -Value "Yes"
        if ($dc.OperatingSystem -like "*2003*" -or $dc.OperatingSystem -like "*2000*") {
            $dc.Supported = "No"
        }
        foreach ($s in $Servers) {
            if ($s -eq $dc.Hostname -or $s -eq $dc.Name) {
                $dc.Reporting = $true
            }
        }
    }
    return $DomainControllers
}

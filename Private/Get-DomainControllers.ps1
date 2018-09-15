function Get-DomainControllers($Servers) {
    $DomainControllers = @()
    try {
        $DomainControllers = Get-ADDomainController -Filter * -ErrorAction 'Stop' | Select-Object Name , HostName, Ipv4Address, IsGlobalCatalog, IsReadOnly, OperatingSystem, Site, Enabled #, Supported, Reporting #,
    } catch {
        if ($_.Exception -match "Unable to find a default server with Active Directory Web Services running.") {
            Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
        }
        Write-Color @script:WriteParameters "[i] Error: ", "$($_.Exception.Message)" -Color White, Red
    }
    foreach ($dc in $DomainControllers) {
        Add-Member -InputObject $dc -MemberType NoteProperty -Name "Supported" -Value ""
        Add-Member -InputObject $dc -MemberType NoteProperty -Name "Reporting" -Value ""
        if ($dc.OperatingSystem -like "*2003*" -or $dc.OperatingSystem -like "*2000*") {
            #Add-Member -InputObject $server -MemberType NoteProperty -Name "Supported" -Value "No"
            $dc.Supported = "No"
        } else {
            #Add-Member -InputObject $server -MemberType NoteProperty -Name "Supported" -Value "Yes"
            $dc.Supported = "Yes"
        }
        foreach ($s in $servers) {
            if ($s -eq $dc.Hostname -or $s -eq $dc.Name) {
                $dc.Reporting = $true
            }
        }
    }
    return $DomainControllers
}

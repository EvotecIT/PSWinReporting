function Get-DC {
    param()
    $DCs = @()
    try {
        $Forest = Get-ADForest -ErrorAction Stop
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        Write-Color @script:WriteParameters "[i] Get-ADForest Error: ", "$($_.Exception.Message)" -Color White, Red
        #return $ErrorMessage
    }
    foreach ($DomainName in $Forest.Domains) {
        $Domain = Get-AdDomain -Server $DomainName -ErrorAction SilentlyContinue
        try {
            $DomainControllers = $(Get-ADDomainController -Server $DomainName -Filter * -ErrorAction Stop )
            foreach ($Policy in $DomainControllers) {
                $DCs += [ordered] @{
                    'Name'             = $Policy.Name
                    'Domain'           = $DomainName
                    'Host Name'        = $Policy.HostName
                    'Operating System' = $Policy.OperatingSystem
                    'Site'             = $Policy.Site
                    'Ipv4'             = if ($Policy.Ipv4Address -eq '') { 'N/A' } else { $Policy.Ipv4Address }
                    'Ipv6'             = if ($Policy.Ipv6Address -eq '') { 'N/A' } else { $Policy.Ipv4Address }
                    'Is GC'            = $Policy.IsGlobalCatalog
                    'Is ReadOnly'      = $Policy.IsReadOnly
                    'Is PDC'           = if ($Policy.HostName -eq $Domain.PDCEmulator) { 'Yes' } else { 'No' }
                    'Is Supported'     = if ($Policy.OperatingSystem -notlike "*2003*" -and $Policy.OperatingSystem -notlike "*2000*") { 'Yes' } else { 'No' }
                    'Is Included'      = ''
                    'Enabled'          = $Policy.Enabled
                }
            }
        } catch {
            if ($_.Exception -match "Unable to find a default server with Active Directory Web Services running.") {
                Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
            }
            Write-Color @script:WriteParameters "[i] Get-ADDomainController Error: ", "$($_.Exception.Message)" -Color White, Red
        }

    }
    return Format-TransposeTable $DCs
}
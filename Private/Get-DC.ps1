function Get-DC {
	param()
	try {
		$Forest = Get-ADForest
	} catch {
		$ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
		$Logger.AddErrorRecord("Get-ADForest Error: $ErrorMessage")
		exit
	}
	$DCs = @()
	foreach ($DomainName in $Forest.Domains) {
		try {
			$Domain = Get-AdDomain -Server $DomainName
			$DomainControllers = Get-ADDomainController -Server $DomainName -Filter *
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
			$ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
			switch ($ErrorMessage) {
				{$_ -match 'The server has rejected the client credentials'} {
					$Logger.AddErrorRecord('Domain Controller has rejected the client credentials. Please run this script with access to Domain Controllers')
				}
				{$_ -match 'Unable to find a default server with Active Directory Web Services running' } {
					$Logger.AddErrorRecord('Active Directory not found. Please run this script with access to Domain Controllers')
				}
				default {
					$Logger.AddErrorRecord("Get-DC Error: $ErrorMessage")
				}
			}
			exit
		}
	}
	return Format-TransposeTable $DCs
}
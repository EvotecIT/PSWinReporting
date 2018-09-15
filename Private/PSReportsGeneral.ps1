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
                    'Is PDC'           = if ($Policy.HostName -eq $Domain.PDCEmulator) { 'No' } else { 'Yes' }
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

function Find-AllEvents($ReportDefinitions, $LogNameSearch, [switch] $All) {
    $EventsToProcess = @()
    foreach ($report in $ReportDefinitions.ReportsAD.EventBased.GetEnumerator()) {
        $ReportName = $report.Name
        $Enabled = $ReportDefinitions.ReportsAD.EventBased.$ReportName.Enabled
        $LogName = $ReportDefinitions.ReportsAD.EventBased.$ReportName.LogName
        $Events = $ReportDefinitions.ReportsAD.EventBased.$ReportName.Events
        #$IgnoreWords = $ReportDefinitions.ReportsAD.EventBased.$ReportName.IgnoreWords

        if ($Enabled -eq $true -or $All -eq $true) {
            if ($LogNameSearch -eq $LogName) {
                $EventsToProcess += $Events
            }
        }
    }
    return $EventsToProcess
}

function Get-AllRequiredEvents {
    param(
        $Servers,
        $Dates,
        $Events,
        $LogName,
        $Verbose = $false
    )
    $Count = Get-Count $Events
    if ($Count -ne 0) {
        return  Get-Events -Server $Servers -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $Events -LogName $LogName -Verbose:$Verbose
        #Get-Events -Server $Servers -EventID $Events -LogName $LogName -Verbose
    }
}

function Get-Count($Object) {
    return $($Object | Measure-Object).Count
}

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

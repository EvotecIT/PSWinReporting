function Start-ADReporting () {
    param (
        [System.Collections.IDictionary]$EmailParameters,
        [System.Collections.IDictionary]$FormattingParameters,
        [System.Collections.IDictionary]$ReportOptions,
        [System.Collections.IDictionary]$ReportTimes,
        [System.Collections.IDictionary]$ReportDefinitions
    )
    Set-DisplayParameters -ReportOptions $ReportOptions

    Test-Prerequisite $EmailParameters $FormattingParameters $ReportOptions $ReportTimes $ReportDefinitions
    if ($null -ne $ReportOptions.JustTestPrerequisite -and $ReportOptions.JustTestPrerequisite -eq $true) {
        Exit
    }

    ## Added for compatibility reasons
    if (-not $ReportOptions.Contains('RemoveDuplicates')) {
        $ReportOptions.RemoveDuplicates = $false
    }
    if (-not $ReportOptions.Contains('SendMailOnlyOnEvents')) {
        $ReportOptions.SendMailOnlyOnEvents = $false
    }
    
    if (-not $ReportDefinitions.ReportsAD.Servers.Contains('UseDirectScan')) {
        if ($ReportOptions.ReportsAD.Servers.UseForwarders) {
            $ReportDefinitions.ReportsAD.Servers.UseDirectScan = $false
        } else {
            $ReportDefinitions.ReportsAD.Servers.UseDirectScan = $true
        }        
    }
    if (-not $ReportDefinitions.ReportsAD.Servers.Contains('UseForwarders')) {
        $ReportDefinitions.ReportsAD.Servers.UseDirectScan = $true
    }

    $Dates = Get-ChoosenDates -ReportTimes $ReportTimes
    foreach ($Date in $Dates) {
        Start-Report -Dates $Date -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
    }
}
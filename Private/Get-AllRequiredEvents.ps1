function Get-AllRequiredEvents {
    param(
        $Servers,
        $Dates,
        $Events,
        $LogName,
        $Verbose = $false
    )
    $Count = Get-ObjectCount $Events
    if ($Count -ne 0) {
        return  Get-Events -Server $Servers -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $Events -LogName $LogName -Verbose:$Verbose
        #Get-Events -Server $Servers -EventID $Events -LogName $LogName -Verbose
    }
}
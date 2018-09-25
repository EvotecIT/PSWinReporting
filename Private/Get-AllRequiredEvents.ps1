function Get-AllRequiredEvents {
    param(
        $Servers,
        [alias('File')][string] $FilePath,
        $Dates,
        $Events,
        [string] $LogName,
        [bool] $Verbose = $false
    )
    $Count = Get-ObjectCount $Events
    if ($Count -ne 0) {
        if ($FilePath) {
            return  Get-Events -Path $FilePath -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $Events -LogName $LogName -Verbose:$Verbose
        } else {
            return  Get-Events -Server $Servers -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $Events -LogName $LogName -Verbose:$Verbose
        }
    }
}
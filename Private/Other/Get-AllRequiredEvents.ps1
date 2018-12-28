function Get-AllRequiredEvents {
    [CmdletBinding()]
    param(
        $Servers,
        [alias('File')][string] $FilePath,
        $Dates,
        $Events,
        [string] $LogName #,
        # [bool] $Verbose = $false
    )
    $Verbose = ($PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true)
    $Count = Get-ObjectCount $Events
    if ($Count -ne 0) {
        if ($FilePath) {
            $MyEvents = Get-Events -Path $FilePath -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo `
                -EventID $Events `
                -LogName $LogName `
                -ErrorAction SilentlyContinue `
                -ErrorVariable ErrorsReturned `
                -Verbose:$Verbose

        } else {
            $MyEvents = Get-Events -Server $Servers -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $Events `
                -LogName $LogName `
                -ErrorAction SilentlyContinue `
                -ErrorVariable ErrorsReturned `
                -Verbose:$Verbose

        }

        foreach ($MyError in $ErrorsReturned) {
            Write-Error -Message $MyError
        }
        return $MyEvents
    }
}
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
            $MyEvents = Get-Events -Path $FilePath -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $Events -LogName $LogName -Verbose:$Verbose
            # $MyEvents | Add-Member -MemberType NoteProperty -Name "GatheredFrom" -Value $FilePath -Force
            # $MyEvents | Add-Member -MemberType NoteProperty -Name "GatheredLog" -Value $LogName -Force
            return $MyEvents
        } else {
            #  $ListServers = $Servers -join ','
            $MyEvents = Get-Events -Server $Servers -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $Events -LogName $LogName -Verbose:$Verbose
            #  $MyEvents | Add-Member -MemberType NoteProperty -Name "GatheredFrom" -Value $ListServers -Force
            #  $MyEvents | Add-Member -MemberType NoteProperty -Name "GatheredLog" -Value $LogName -Force
            return $MyEvents
        }
    }
}
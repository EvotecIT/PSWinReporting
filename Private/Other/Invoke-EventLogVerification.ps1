function Invoke-EventLogVerification {
    [CmdletBinding()]
    param(
        $Results,
        $Dates
    )
    $Logs = @()
    foreach ($result in $Results) {

        if ($result.EventOldest -gt $Dates.DateFrom) {
            $Logger.AddWarningRecord("$($Result.LogName) log on $($Result.Server) doesn't cover whole date range requested. Oldest event $($Result.EventOldest) while requested $($Dates.DateFrom).")
           # Write-Color @script:WriteParameters '[W] ', 'Warning: ', $result.LogName, ' log on ', $result.Server, " doesn't cover whole date range requested. Oldest event ", $result.EventOldest, ' while requested ', $Dates.DateFrom, '.' -Color Blue, White, Yellow, White, Yellow, White, Yellow, White, Yellow
            $Logs += "<strong>$($result.LogName)</strong> log on <strong>$($result.Server)</strong> doesn't cover whole date range requested. Oldest event <strong>$($result.EventOldest)</strong> while requested <strong>$($Dates.DateFrom)</strong>."
        }
    }
    return $Logs
}
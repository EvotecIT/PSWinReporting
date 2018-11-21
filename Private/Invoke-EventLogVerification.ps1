function Invoke-EventLogVerification ($Results, $Dates) {
    $Logs = @()
    foreach ($result in $Results) {
        if ($result.EventOldest -gt $Dates.DateFrom) {
            $Logger.AddWarningRecord("$($result.LogName) log on $($result.Server) doesn't cover whole date range requested. Oldest event $($result.EventOldest) while requested $($Dates.DateFrom)")
            $Logs += "<strong>$($result.LogName)</strong> log on <strong>$($result.Server)</strong> doesn't cover whole date range requested. Oldest event <strong>$($result.EventOldest)</strong> while requested <strong>$($Dates.DateFrom)</strong>."
        }
    }
    return $Logs
}
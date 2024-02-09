function Invoke-EventLogVerification ($Results, $Dates) {

    $Logs = @()
    foreach ($result in $Results) {

        if ($result.EventOldest -gt $Dates.DateFrom) {
            Write-Color @script:WriteParameters '[W] ', 'Warning: ', $result.LogName, ' log on ', $result.Server, " doesn't cover whole date range requested. Oldest event ", $result.EventOldest.ToString(), ' while requested ', $Dates.DateFrom.ToString(), '.' -Color Blue, White, Yellow, White, Yellow, White, Yellow, White, Yellow
            $Logs += "<strong>$($result.LogName)</strong> log on <strong>$($result.Server)</strong> doesn't cover whole date range requested. Oldest event <strong>$($result.EventOldest.ToString())</strong> while requested <strong>$($Dates.DateFrom.ToString())</strong>."
        }
    }
    return $Logs
}
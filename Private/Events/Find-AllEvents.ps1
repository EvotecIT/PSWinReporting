function Find-AllEvents {
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $ReportDefinitions,
        [string] $LogNameSearch,
        [switch] $All
    )
    $EventsToProcess = foreach ($report in $ReportDefinitions.ReportsAD.EventBased.GetEnumerator()) {
        $ReportName = $report.Name
        $Enabled = $ReportDefinitions.ReportsAD.EventBased.$ReportName.Enabled
        $LogName = $ReportDefinitions.ReportsAD.EventBased.$ReportName.LogName
        $Events = $ReportDefinitions.ReportsAD.EventBased.$ReportName.Events
        #$IgnoreWords = $ReportDefinitions.ReportsAD.EventBased.$ReportName.IgnoreWords

        if ($Enabled -eq $true -or $All -eq $true) {
            if ($LogNameSearch -eq $LogName) {
                $Events
            }
        }
    }

    return $EventsToProcess
}
function Get-MyEvents {
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $ReportDefinition,
        [string] $ReportName
    )
    $Logger.AddInfoRecord("Running $ReportName Report")
    $ExecutionTime = Start-TimeLog

    foreach ($Report in $ReportDefinition.Keys | Where-Object { $_ -ne 'Enabled' }) {
        $EventsType = $ReportDefinition[$Report].LogName
        $EventsNeeded = $ReportDefinition[$Report].Events
        $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
        $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $ReportDefinition[$Report]
        $EventsFound
    }

    $Elapsed = Stop-TimeLog -Time $ExecutionTime -Option OneLiner
    $Logger.AddInfoRecord("Ending $ReportName Report - Time elapsed: $Elapsed")
}
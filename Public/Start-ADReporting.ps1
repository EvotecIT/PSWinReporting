function Start-ADReporting () {
    param (
        [hashtable]$EmailParameters,
        [hashtable]$FormattingParameters,
        [hashtable]$ReportOptions,
        [hashtable]$ReportTimes,
        [hashtable]$ReportDefinitions
    )
    Set-DisplayParameters -ReportOptions $ReportOptions

    Test-Prerequisite $EmailParameters $FormattingParameters $ReportOptions $ReportTimes $ReportDefinitions
    if ($ReportOptions.JustTestPrerequisite -ne $null -and $ReportOptions.JustTestPrerequisite -eq $true) {
        Exit
    }

    $Dates = Get-ChoosenDates -ReportTimes $ReportTimes
    foreach ($Date in $Dates) {
        Start-Report -Dates $Date -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
    }
}
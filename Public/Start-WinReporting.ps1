function Start-WinReporting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$LoggerParameters,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$EmailParameters,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$FormattingParameters,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$ReportOptions,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$ReportTimes,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$ReportDefinitions,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Target
    )

    # Logger Setup
    [bool] $WarningNoLogger = $false

    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
        $WarningNoLogger = $true
    }

    $Params = @{
        LogPath    = if ([string]::IsNullOrWhiteSpace($LoggerParameters.LogsDir)) { '' } else { Join-Path $LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log" }
        ShowTime   = $LoggerParameters.ShowTime
        TimeFormat = $LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params

    if ($WarningNoLogger) {
        $Logger.AddWarningRecord("New version of PSWinReporting requires Logger Parameter. Please read documentation. No logs will be written to disk.")
    }

    # Test Configuration



    # Test Modules


    # Run report
    $Dates = Get-ChoosenDates -ReportTimes $ReportTimes
    foreach ($Date in $Dates) {
        $Logger.AddInfoRecord("Starting to build a report for dates $($Date.DateFrom) to $($Date.DateTo)")
        Start-ReportSpecial `
            -Dates $Date `
            -EmailParameters $EmailParameters `
            -FormattingParameters $FormattingParameters `
            -ReportOptions $ReportOptions `
            -ReportDefinitions $ReportDefinitions `
            -Target $Target
    }
}
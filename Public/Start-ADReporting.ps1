function Start-ADReporting () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [System.Collections.IDictionary]$LoggerParameters,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$EmailParameters,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$FormattingParameters,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$ReportOptions,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$ReportTimes,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$ReportDefinitions
    )
    [bool] $WarningNoLogger = $false
    <#
        Set logger
    #>
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

    <#
        Test Configuration
    #>
    $Params = @{
        LoggerParameters     = $LoggerParameters
        EmailParameters      = $EmailParameters
        FormattingParameters = $FormattingParameters
        ReportOptions        = $ReportOptions
        ReportTimes          = $ReportTimes
        ReportDefinitions    = $ReportDefinitions
    }
    if (-not (Test-Configuration @Params)) {
        $Logger.AddErrorRecord("There are parameters missing in configuration file. Can't continue running.")
        exit
    }

    <#
        Test Modules
    #>
    if (-not (Test-Modules -ReportOptions $ReportOptions)) {
        $Logger.AddErrorRecord("Install the necessary modules. Can't continue running.")
    }

    if ($ReportOptions.JustTestPrerequisite) {
        exit
    }

    <#
        Test AD availability
    #>
    try {
        $null = Get-ADDomain
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        $Logger.AddErrorRecord("Failed to get AD domain information: $ErrorMessage)")
        exit
    }

    $Logger.AddInfoRecord('Starting to build a report')
    $Dates = Get-ChoosenDates -ReportTimes $ReportTimes
    foreach ($Date in $Dates) {
        Start-Report -Dates $Date -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions -ReportDefinitions $ReportDefinitions
    }
}
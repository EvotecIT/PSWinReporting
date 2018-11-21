function Start-ADReporting () {
    param (
        [hashtable]$LoggerParameters,
        [hashtable]$EmailParameters,
        [hashtable]$FormattingParameters,
        [hashtable]$ReportOptions,
        [hashtable]$ReportTimes,
        [hashtable]$ReportDefinitions
    )

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version Latest
    
    <#
        Set logger
    #>
    $Params = @{
        LogPath = Join-Path $LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log"
        ShowTime = $LoggerParameters.ShowTime
        TimeFormat = $LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params

    <#
        Test Configuration
    #>
    $Params = @{
        LoggerParameters    =$LoggerParameters
        EmailParameters     =$EmailParameters
        FormattingParameters =$FormattingParameters
        ReportOptions       =$ReportOptions
        ReportTimes         =$ReportTimes
        ReportDefinitions   =$ReportDefinitions
    }
    if (-not (Test-Configuration @Params)) {
        $Logger.AddErrorRecord("There are parameters missing in configuration file. Can't continue running.")
        exit
    }

    <#
        Test Modules
    #>
    if (-not (Test-Modules $ReportOptions)) {
        $Logger.AddErrorRecord("Install the necessary modules. Can't continue running.")
    }

    if ($ReportOptions.JustTestPrerequisite -and $ReportOptions.JustTestPrerequisite -eq $true) {
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
function Start-SubscriptionService {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $LoggerParameters
    )

    $Params = @{
        LogPath = Join-Path $LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log"
        ShowTime = $LoggerParameters.ShowTime
        TimeFormat = $LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params

    $Logger.AddInfoRecord('Starting Windows Event Collector service.')
    #Write-Color 'Starting Windows Event Collector service.' -Color White, Green, White
    $Output = Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'qc', '/q:true'
    $Logger.AddInfoRecord($Output)
}

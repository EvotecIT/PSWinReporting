function Start-SubscriptionService {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $LoggerParameters
    )
    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters
    $Logger.AddInfoRecord('Starting Windows Event Collector service.')
    #Write-Color 'Starting Windows Event Collector service.' -Color White, Green, White
    $Output = Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'qc', '/q:true'
    $Logger.AddInfoRecord($Output)
}

function Start-WinSubscriptionService {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $LoggerParameters
    )
    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters
    $Logger.AddInfoRecord('Starting Windows Event Collector service.')
    $Output = Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'qc', '/q:true'
    $Logger.AddInfoRecord($Output)
}
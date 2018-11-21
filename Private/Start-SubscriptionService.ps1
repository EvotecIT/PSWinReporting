function Start-SubscriptionService {
    [CmdletBinding()]
    param()
    $Logger.AddInfoRecord("Starting Windows Event Collector service")
    Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'qc', '/q:true'
}

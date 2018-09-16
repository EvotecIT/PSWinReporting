function Start-SubscriptionService {
    [CmdletBinding()]
    param()
    Write-Color 'Starting Windows Event Collector service.' -Color White, Green, White
    Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'qc', '/q:true'
}

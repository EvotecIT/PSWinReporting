function Remove-Subscription {
    [CmdletBinding()]
    param(
        [switch] $All,
        [switch] $Own
    )
    $Subscriptions = Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'es'
    foreach ($Subscription in $Subscriptions) {
        if ($Own -and $Subscription -like '*PSWinReporting*') {
            $Logger.AddRecord("Deleting own providers: $Subscription")
            Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'ds', $Subscription
        }
        if ($All -and $Subscription -notlike '*PSWinReporting*') {
            $Logger.AddRecord("Deleting all providers: $Subscription")
            Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'ds', $Subscription
        }
    }
}
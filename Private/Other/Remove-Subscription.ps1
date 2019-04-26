function Remove-Subscription {
    [CmdletBinding()]
    param(
        [switch] $All,
        [switch] $Own,
        [System.Collections.IDictionary] $LoggerParameters
    )
    $Subscriptions = Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'es'
    foreach ($Subscription in $Subscriptions) {
        if ($Own -eq $true -and $Subscription -like '*PSWinReporting*') {
            $Logger.AddInfoRecord("Deleting own providers - $Subscription")
            #Write-Color 'Deleting own providers - ', $Subscription -Color White, Green
            Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'ds', $Subscription -LoggerParameters $LoggerParameters
        }
        if ($All -eq $true -and $Subscription -notlike '*PSWinReporting*') {
            $Logger.AddInfoRecord("Deleting own providers - $Subscription")
            #Write-Color 'Deleting all providers - ', $Subscription -Color White, Green
            Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'ds', $Subscription -LoggerParameters $LoggerParameters
        }

    }
}
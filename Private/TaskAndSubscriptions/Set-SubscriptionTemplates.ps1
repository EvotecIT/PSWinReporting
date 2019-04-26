function Set-SubscriptionTemplates {
    [CmdletBinding()]
    param(
        [System.Array] $ListTemplates,
        [switch] $DeleteOwn,
        [switch] $DeleteAllOther,
        [System.Collections.IDictionary] $LoggerParameters
    )

    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters

    if ($DeleteAll -or $DeleteOwn) {
        Remove-Subscription -All:$DeleteAllOther -Own:$DeleteOwn -LoggerParameters $LoggerParameters
    }
    foreach ($TemplatePath in $ListTemplates) {
        #Write-Color 'Adding provider ', $TemplatePath, ' to Subscriptions.' -Color White, Green, White
        $Logger.AddInfoRecord("Adding provider $TemplatePath to Subscriptions.")
        Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'cs', $TemplatePath -LoggerParameters $LoggerParameters
    }
}
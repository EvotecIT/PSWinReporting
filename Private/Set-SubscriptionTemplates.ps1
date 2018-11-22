function Set-SubscriptionTemplates {
    [CmdletBinding()]
    param(
        [System.Array] $ListTemplates,
        [switch] $DeleteOwn,
        [switch] $DeleteAllOther
    )
    if ($DeleteAll -or $DeleteOwn) {
        Remove-Subscription -All:$DeleteAllOther -Own:$DeleteOwn
    }
    foreach ($TemplatePath in $ListTemplates) {
        Write-Color 'Adding provider ', $TemplatePath, ' to Subscriptions.' -Color White, Green, White
        Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'cs', $TemplatePath
    }
}
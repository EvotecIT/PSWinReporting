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
        $Logger.AddRecord("Adding provider $TemplatePath  to Subscriptions")
        Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'cs', $TemplatePath
    }
}
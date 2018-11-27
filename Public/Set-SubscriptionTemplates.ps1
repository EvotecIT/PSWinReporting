function Set-SubscriptionTemplates {
    [CmdletBinding()]
    param(
        [System.Array] $ListTemplates,
        [switch] $DeleteOwn,
        [switch] $DeleteAllOther,
        $LoggerParameters
    )

    $Params = @{
        LogPath = Join-Path $LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log"
        ShowTime = $LoggerParameters.ShowTime
        TimeFormat = $LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params

    if ($DeleteAll -or $DeleteOwn) {
        Remove-Subscription -All:$DeleteAllOther -Own:$DeleteOwn
    }
    foreach ($TemplatePath in $ListTemplates) {
        #Write-Color 'Adding provider ', $TemplatePath, ' to Subscriptions.' -Color White, Green, White
        $Logger.AddInfoRecord("Adding provider $TemplatePath to Subscriptions.")
        Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'cs', $TemplatePath
    }
}
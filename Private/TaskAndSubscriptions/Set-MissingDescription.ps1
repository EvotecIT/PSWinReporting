function Set-MissingDescription {
    [CmdletBinding()]
    param(

    )
    $AllSubscriptions = Start-MyProgram -Program $ProgramWecutil -cmdArgList 'es'

    foreach ($Subscription in $AllSubscriptions) {
        $SubData = Start-MyProgram -Program $ProgramWecutil -cmdArgList 'gs', $Subscription
        Find-MyProgramData -Data $SubData -FindText 'ContentFormat*'

        $Change = Start-MyProgram -Program $ProgramWecutil -cmdArgList 'ss', $Subscription, '/cf:Events'
    }
}

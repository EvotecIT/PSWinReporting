function Remove-TaskScheduledForwarder {
    [CmdletBinding()]
    param(
        $TaskPath = '\Event Viewer Tasks\',
        $TaskName = 'ForwardedEvents'
    )
    Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false
}
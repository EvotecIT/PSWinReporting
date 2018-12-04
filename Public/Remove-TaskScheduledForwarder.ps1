function Remove-TaskScheduledForwarder {
    [CmdletBinding()]
    param(
        $TaskPath = '\Event Viewer Tasks\',
        $TaskName = 'ForwardedEvents'
    )
    try {
        Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false -ErrorAction Stop
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        switch ($ErrorMessage) {
            {$_ -match 'No matching MSFT_ScheduledTask objects found by CIM query for instances of the'} {
                Write-Color -Text 'No tasks exists. Nothing to remove.' -Color Yellow
            }
            default {
                Write-Color -Text "Tasks removal error:" , $ErrorMessage -Color White, Red
            }
        }
    }
}
function Remove-WinTaskScheduledForwarder {
    [CmdletBinding()]
    param(
        [string] $TaskPath = '\Event Viewer Tasks\',
        [string] $TaskName = 'ForwardedEvents',
        [System.Collections.IDictionary] $LoggerParameters
    )
    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters
    try {
        Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false -ErrorAction Stop
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        switch ($ErrorMessage) {
            {$_ -match 'No matching MSFT_ScheduledTask objects found by CIM query for instances of the'} {
                $Logger.AddInfoRecord("No tasks exists. Nothing to remove")
            }
            default {
                $Logger.AddErrorRecord("Tasks removal error: $ErrorMessage")
            }
        }
    }
}
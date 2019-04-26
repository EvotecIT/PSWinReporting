function Add-WinTaskScheduledForwarder {
    [CmdletBinding()]
    param(
        [string] $TaskPath = '\Event Viewer Tasks\',
        [string] $TaskName = 'ForwardedEvents',
        [string] $Author = 'Evotec',
        [string] $URI = '\Event Viewer Tasks\ForwardedEvents',
        [string] $Command = 'powershell.exe',
        [Array] $Argument = @('-windowstyle hidden', 'C:\Support\GitHub\PSWinReporting\Examples\Trigger.ps1', "-EventID $(eventID) -eventRecordID '$(eventRecordID)' -eventChannel '$(eventChannel)' -eventSeverity $(eventSeverity)"),
        [System.Collections.IDictionary] $LoggerParameters
    )
    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters
    $XmlTemplate = "$PSScriptRoot\..\Templates\Template-ScheduledTask.xml"
    if (Test-Path $xmlTemplate) {
        Write-Color 'Found Template ', $xmlTemplate -Color White, Yellow
        $ListTemplates = New-ArrayList
        if (Test-Path $xmlTemplate) {
            $ScheduledTaskXML = "$ENV:TEMP\PSWinReportingSchedluledTask.xml"
            Copy-Item -Path $xmlTemplate $ScheduledTaskXML
            Write-Color 'Copied template ', $ScheduledTaskXML -Color White, Yellow
            Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'RegistrationInfo' -Node 'Author' -Value $Author
            Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'Actions', 'Exec' -Node 'Command' -Value $Command
            Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'Actions', 'Exec' -Node 'Arguments' -Value ([string] $Argument)

            $xml = (get-content $ScheduledTaskXML | out-string)
            try {
                $Output = Register-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -xml $xml
            } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                switch ($ErrorMessage) {
                    default {
                        $Logger.AddErrorRecord("Tasks adding error occured: $ErrorMessage")
                    }
                }
                Exit
            }
            $Logger.AddInfoRecord("Loaded template $ScheduledTaskXML")
        }
    } else {
        $Logger.AddErrorRecord("Template not found $xmlTemplate")
    }
}
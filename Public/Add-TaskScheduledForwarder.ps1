function Add-TaskScheduledForwarder {
    [CmdletBinding()]
    param(
        [string] $TaskPath = '\Event Viewer Tasks\',
        [string] $TaskName = 'ForwardedEvents',
        [string] $Author = 'Evotec',
        [string] $URI = '\Event Viewer Tasks\ForwardedEvents',
        [string] $Command = 'powershell.exe',
        [Array] $Argument = @('-windowstyle hidden', 'C:\Support\GitHub\PSWinReporting\Examples\Trigger.ps1', "-EventID $(eventID) -eventRecordID '$(eventRecordID)' -eventChannel '$(eventChannel)' -eventSeverity $(eventSeverity)")

    )
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
                        Write-Color -Text "Tasks adding error occured:" , $ErrorMessage -Color White, Red
                    }
                }
                Exit
            }
            Write-Color -Text 'Loaded template ', $ScheduledTaskXML -Color White, Yellow
        }
    } else {
        Write-Color -Text 'Template not found ', $xmlTemplate -Color White, Yellow
    }
}
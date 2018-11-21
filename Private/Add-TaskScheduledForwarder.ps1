function Add-TaskScheduledForwarder {
    [CmdletBinding()]
    param(
        $TaskPath = '\Event Viewer Tasks\',
        $TaskName = 'ForwardedEvents',
        $Author = 'Evotec',
        $URI = '\Event Viewer Tasks\ForwardedEvents',
        $Command = 'powershell.exe',
        $Argument = @('-windowstyle hidden', 'C:\Support\GitHub\PSWinReporting\Examples\Trigger.ps1', "-EventID $(eventID) -eventRecordID '$(eventRecordID)' -eventChannel '$(eventChannel)' -eventSeverity $(eventSeverity)")

    )
    $XmlTemplate = Join-Path (Get-Item $PSScriptRoot).Parent.FullName 'Templates\Template-ScheduledTask.xml'
    
    if (Test-Path $XmlTemplate) {
        $Logger.AddRecord("Found Template $XmlTemplate")
        $ListTemplates = New-ArrayList
        if (Test-Path $XmlTemplate) {
            $ScheduledTaskXML = Join-Path $env:Temp 'PSWinReportingSchedluledTask.xml'
            Copy-Item -Path $XmlTemplate $ScheduledTaskXML
            $Logger.AddRecord("Copied template $ScheduledTaskXML")
            Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'RegistrationInfo' -Node 'Author' -Value $Author
            Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'Actions', 'Exec' -Node 'Command' -Value $Command
            Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'Actions', 'Exec' -Node 'Arguments' -Value ([string] $Argument)
            #  Invoke-Item $ScheduledTaskXML

            $xml = (Get-Content $ScheduledTaskXML | Out-String)
            #  $xml

            Register-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -xml $xml
            $Logger.AddRecord("Loaded template $ScheduledTaskXML")
        }
    } else {
        $Logger.AddRecord("Template not found $XmlTemplate")
    }
}
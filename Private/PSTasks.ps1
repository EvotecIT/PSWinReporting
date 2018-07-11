function Remove-TaskScheduledForwarder {
    param(
        $TaskPath = '\Event Viewer Tasks\',
        $TaskName = 'ForwardedEvents'
    )
    Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Confirm:$false
}

function Add-TaskScheduledForwarder {
    param(
        $TaskPath = '\Event Viewer Tasks\',
        $TaskName = 'ForwardedEvents',
        $Author = 'Evotec',
        $URI = '\Event Viewer Tasks\ForwardedEvents',
        $Command = 'powershell.exe',
        $Argument = @('-windowstyle hidden', 'C:\Support\GitHub\PSWinReporting\Examples\Trigger.ps1', "-EventID $(eventID) -eventRecordID '$(eventRecordID)' -eventChannel '$(eventChannel)' -eventSeverity $(eventSeverity)")

    )
    $xmlTemplate = "$($(Get-Module -ListAvailable PSWinReporting).ModuleBase)\Templates\Template-ScheduledTask.xml"
    $ListTemplates = New-ArrayList
    if (Test-Path $xmlTemplate) {
        $ScheduledTaskXML = "$ENV:TEMP\PSWinReportingSchedluledTask.xml"
        Copy-Item -Path $xmlTemplate $ScheduledTaskXML
        Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'RegistrationInfo' -Node 'Author' -Value $Author
        Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'Actions', 'Exec' -Node 'Command' -Value $Command
        Set-XML -FilePath $ScheduledTaskXML -Paths 'Task', 'Actions', 'Exec' -Node 'Arguments' -Value ([string] $Argument)
        #  Invoke-Item $ScheduledTaskXML

        $xml = (get-content $ScheduledTaskXML | out-string)
        #  $xml

        Register-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -xml $xml
    }
}
<#
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2"
  xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2018-07-05T12:56:06.3370415</Date>
    <Author>EVOTEC</Author>
    <URI>\Event Viewer Tasks\ForwardedEvents</URI>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="ForwardedEvents"&gt;&lt;Select Path="ForwardedEvents"&gt;*&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
      <ValueQueries>
        <Value name="eventChannel">Event/System/Channel</Value>
        <Value name="eventRecordID">Event/System/EventRecordID</Value>
        <Value name="eventSeverity">Event/System/Level</Value>
        <Value name="eventID">Event/System/EventID</Value>
      </ValueQueries>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-21-853615985-2870445339-3163598659-1105</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-windowstyle hidden C:\Support\GitHub\PSWinReporting\Examples\Trigger.ps1 -EventID $(eventID) -eventRecordID '$(eventRecordID)' -eventChannel '$(eventChannel)' -eventSeverity $(eventSeverity)</Arguments>
    </Exec>
  </Actions>
</Task>
#>
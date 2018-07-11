Unregister-ScheduledTask -TaskPath '\Event Viewer Tasks\' -TaskName 'ForwardedEvents 1' -Confirm:$false

#Register-ScheduledTask -Xml  -TaskName "Weekly System Info Report" -User globomantics\administrator -Password P@ssw0rd –Force

$xml = (get-content "$PSScriptRoot\..\Forwarders\ForwardedEvents.XML" | out-string)

Register-ScheduledTask -TaskPath '\Event Viewer Tasks\' -TaskName 'ForwardedEvents 1' -xml $xml



$Script = @('-windowstyle hidden', 'C:\Support\GitHub\PSWinReporting\Examples\RunMe-TriggerOnEvents.ps1', '-EventID $(eventID) -eventRecordID $(eventRecordID) -eventChannel $(eventChannel) -eventSeverity $(eventSeverity)')
Add-TaskScheduledForwarder -Author 'Misiek' -URI '\Event Viewer Tasks\ForwardedEvents' -Command 'powershell.exe' -Argument $Script
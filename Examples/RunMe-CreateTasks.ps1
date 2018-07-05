Unregister-ScheduledTask -TaskPath '\Event Viewer Tasks\' -TaskName 'ForwardedEvents' -Confirm:$false

#Register-ScheduledTask -Xml  -TaskName "Weekly System Info Report" -User globomantics\administrator -Password P@ssw0rd –Force

$xml = (get-content "$PSScriptRoot\..\Forwarders\ForwardedEvents.XML" | out-string)

Register-ScheduledTask -TaskPath '\Event Viewer Tasks\' -TaskName 'ForwardedEvents 1' -xml $xml
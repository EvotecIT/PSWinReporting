Import-Module PSWinReporting #-Force
Import-Module PSSharedGoods #-Force

$TaskName = 'ForwardedEvents'
$TaskPath = '\Event Viewer Tasks\'
$Author = 'EVOTEC'
$URI = '\Event Viewer Tasks\ForwardedEvents'
$Command = 'powershell.exe'
$Argument = @('-windowstyle hidden', 'C:\Support\GitHub\PSWinReporting\Examples\RunMe-TriggerOnEvents.ps1', '-EventID $(eventID) -eventRecordID $(eventRecordID) -eventChannel $(eventChannel) -eventSeverity $(eventSeverity)')

Remove-TaskScheduledForwarder -TaskPath $TaskPath -TaskName $TaskName
Add-TaskScheduledForwarder -TaskPath $TaskPath -TaskName $TaskName -Author $Author -URI $Uri -Command $Command -Argument $Argument
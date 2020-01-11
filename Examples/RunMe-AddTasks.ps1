Import-Module "$PSScriptRoot\..\PSWinReporting.psd1" -Force

$TaskName = 'ForwardedEvents'
$TaskPath = '\Event Viewer Tasks\'
$Author = 'EVOTEC'
$URI = '\Event Viewer Tasks\ForwardedEvents'
$Command = 'powershell.exe'
$Argument = @('-windowstyle hidden', "$PSScriptRoot\RunMe-TriggerOnEvents.ps1", '-EventID $(eventID) -eventRecordID $(eventRecordID) -eventChannel $(eventChannel) -eventSeverity $(eventSeverity)')


Remove-TaskScheduledForwarder -TaskPath $TaskPath -TaskName $TaskName
Add-TaskScheduledForwarder -TaskPath $TaskPath -TaskName $TaskName -Author $Author -URI $Uri -Command $Command -Argument $Argument
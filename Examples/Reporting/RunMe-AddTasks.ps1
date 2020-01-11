Import-Module "$PSScriptRoot\..\..\PSWinReportingV2.psd1" -Force

$TaskName = 'ForwardedEvents'
$TaskPath = '\Event Viewer Tasks\'
$Author = 'EVOTEC'
$URI = '\Event Viewer Tasks\ForwardedEvents'
$Command = 'powershell.exe'
$Argument = @('-windowstyle hidden', "$PSScriptRoot\RunMe-TriggerOnEvents.ps1", '-EventID $(eventID) -eventRecordID $(eventRecordID) -eventChannel $(eventChannel) -eventSeverity $(eventSeverity)')

Remove-WinTaskScheduledForwarder -TaskPath $TaskPath -TaskName $TaskName
Add-WinTaskScheduledForwarder -TaskPath $TaskPath -TaskName $TaskName -Author $Author -URI $Uri -Command $Command -Argument $Argument
# Collects all named paramters (all others end up in $Args)
param(
    $eventid = 4757,
    $eventRecordID = 432314, # 425358 ,
    $eventChannel,
    $eventSeverity
)
Import-Module PSTeams -Force
Import-Module PSEventViewer -Force
Import-Module PSWinReporting -Force
Import-Module PSWriteColor -Force

Write-Color 'Executed Trigger for ID: ', $eventid, ' and RecordID: ', $eventRecordID -LogFile 'C:\Log.txt'

$TeamsID = ''
Start-TeamsReport -EventID $EventID -EventRecordID $EventRecordID -EventChannel $EventChannel -TeamsID $TeamsID
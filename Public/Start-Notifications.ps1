function Start-Notifications {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary]$ReportOptions,
        [System.Collections.IDictionary] $ReportDefinitions,
        [int] $EventID,
        [int64] $EventRecordID,
        [string] $EventChannel,
        [System.Collections.IDictionary] $LoggerParameters
    )
    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters
    $Logger.AddInfoRecord("Executed Trigger for ID: $eventid and RecordID: $eventRecordID")
    $Logger.AddInfoRecord("Using Microsoft Teams: $($ReportOptions.Notifications.MicrosoftTeams.Use)")

    if ($ReportOptions.Notifications.MicrosoftTeams.Use) {
        [string] $URI = Format-FirstXChars -Text $ReportOptions.Notifications.MicrosoftTeams.TeamsID -NumberChars 50
        $Logger.AddInfoRecord("TeamsID: $URI...")
    }
    $Logger.AddInfoRecord("Using Slack: $($ReportOptions.Notifications.Slack.Use)")
    if ($ReportOptions.Notifications.Slack.Use) {
        [string] $URI = Format-FirstXChars -Text $ReportOptions.Notifications.Slack.URI -NumberChars 25
        $Logger.AddInfoRecord("Slack URI: $URI...")
        $Logger.AddInfoRecord("Slack Channel: $($($ReportOptions.Notifications.Slack.Channel))...")
    }
    $Logger.AddInfoRecord("Using MSSQL: $($ReportOptions.Notifications.MSSQL.Use)")

    if (-not $ReportOptions.Notifications.Slack.Use -and -not $ReportOptions.Notifications.MicrosoftTeams.Use -and -not $ReportOptions.Notifications.MSSQL.Use) {
        # Terminating as no options are $true
        return
    }

    $Events = Get-Events -Server $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -EventID $eventid -RecordID $eventRecordID -Verbose:$ReportOptions.Debug.Verbose

    # Process events
    $Results = @{}
    foreach ($ReportName in $ReportDefinitions.ReportsAD.EventBased.Keys) {
        if ($ReportDefinitions.ReportsAD.EventBased.$ReportName.Enabled -eq $true) {
            $Logger.AddInfoRecord("Running $ReportName Report")
            $TimeExecution = Start-TimeLog
            $Results.$ReportName = Get-EventsWorkaround -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.$ReportName.IgnoreWords -Report $ReportName
            $ElapsedTime = Stop-TimeLog -Time $TimeExecution -Option OneLiner
            $Logger.AddInfoRecord("Ending $ReportName Report - Elapsed time: $ElapsedTime")
        }
    }

    [bool] $FoundPriorityEvent = $false
    foreach ($ReportName in $ReportDefinitions.ReportsAD.EventBased.Keys) {

        if ($Results.$ReportName) {

            if ($null -ne $ReportDefinitions.ReportsAD.EventBased.$ReportName.Priority) {
                foreach ($Priority in $ReportDefinitions.ReportsAD.EventBased.$ReportName.Priority.Keys) {
                    $MyValue = Find-EventsTo -Prioritize -Events $Results.$ReportName -DataSet  $ReportDefinitions.ReportsAD.EventBased.$ReportName.Priority.$Priority
                    if ((Get-ObjectCount -Object $MyValue) -gt 0) {
                        $Logger.AddInfoRecord("Sending event with $Priority priority.")
                        Send-Notificaton -Events $MyValue -ReportOptions $ReportOptions -Priority $Priority
                        $FoundPriorityEvent = $true
                    }
                }
            }
            if (-not $FoundPriorityEvent) {
                $Logger.AddInfoRecord("Sending event with default priority.")
                Send-Notificaton -Events $Results.$ReportName -ReportOptions $ReportOptions -Priority 'Default'
            }
        }
    }

    if ($ReportOptions.Backup.Use) {
        Protect-ArchivedLogs -TableEventLogClearedLogs $TableEventLogClearedLogs -DestinationPath $ReportOptions.Backup.DestinationPath -Verbose:$ReportOptions.Debug.Verbose
    }
}
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
    <#
        Set logger
    #>
    if (-not $LoggerParameters) {
        $LoggerParameters = @{
            ShowTime   = $true
            LogsDir    = 'C:\temp\logs'
            TimeFormat = 'yyyy-MM-dd HH:mm:ss'
        }
    }

    $Params = @{
        LogPath    = Join-Path $LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log"
        ShowTime   = $LoggerParameters.ShowTime
        TimeFormat = $LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params

    Write-Color @script:WriteParameters -Text '[i] Executed ', 'Trigger', ' for ID: ', $eventid, ' and RecordID: ', $eventRecordID -Color White, Yellow, White, Yellow, White, Yellow

    Write-Color @script:WriteParameters -Text '[i] Using Microsoft Teams: ', $ReportOptions.Notifications.MicrosoftTeams.Use -Color White, Yellow
    if ($ReportOptions.Notifications.MicrosoftTeams.Use) {
        if ($($ReportOptions.Notifications.MicrosoftTeams.TeamsID).Count -gt 50) {
            Write-Color @script:WriteParameters -Text '[i] TeamsID: ', "$($($ReportOptions.Notifications.MicrosoftTeams.TeamsID).Substring(0, 50))..." -Color White, Yellow
        } else {
            Write-Color @script:WriteParameters -Text '[i] TeamsID: ', "$($($ReportOptions.Notifications.MicrosoftTeams.TeamsID))..." -Color White, Yellow
        }
    }
    Write-Color @script:WriteParameters -Text '[i] Using Slack: ', $ReportOptions.Notifications.Slack.Use -Color White, Yellow
    if ($ReportOptions.Notifications.Slack.Use) {
        if ($($ReportOptions.Notifications.Slack.URI).Count -gt 25) {
            Write-Color @script:WriteParameters -Text '[i] Slack URI: ', "$($($ReportOptions.Notifications.Slack.URI).Substring(0, 25))..." -Color White, Yellow
        } else {
            Write-Color @script:WriteParameters -Text '[i] Slack URI: ', "$($($ReportOptions.Notifications.Slack.URI))..." -Color White, Yellow
        }
        Write-Color @script:WriteParameters -Text '[i] Slack Channel: ', "$($($ReportOptions.Notifications.Slack.Channel))" -Color White, Yellow
    }

    Write-Color @script:WriteParameters -Text '[i] Using MSSQL: ', $ReportOptions.Notifications.MSSQL.Use -Color White, Yellow


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

    foreach ($ReportName in $ReportDefinitions.ReportsAD.EventBased.Keys) {
        Send-Notificaton -Events $Results.$ReportName -ReportOptions $ReportOptions
    }

    if ($ReportOptions.Backup.Use) {
        Protect-ArchivedLogs -TableEventLogClearedLogs $TableEventLogClearedLogs -DestinationPath $ReportOptions.Backup.DestinationPath -Verbose:$ReportOptions.Debug.Verbose
    }
}
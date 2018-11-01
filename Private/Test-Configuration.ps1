function Test-Configuration ($EmailParameters, $FormattingParameters, $ReportOptions, $ReportTimes, $ReportDefinitions) {
    Write-Warning "[i] Testing for configuration consistency. This is to make sure the script can be safely executed..."
    if ($EmailParameters -eq $null -or $ReportOptions -eq $null -or $FormattingParameters -eq $null -or $ReportTimes -eq $null -or $ReportDefinitions -eq $null) {
        Write-Warning "[i] There is not enough parameters passed to the Start-Reporting. Make sure there are 4 parameter groups (hashtables). Check documentation - you would be better to just start from scratch!"
        Exit
    }
    Write-Color @script:WriteParameters -Text "[t] ", "Testing for missing parameters in configuration...", "Keep tight!" -Color White, White, Yellow

    # Configuration successful check flag
    $Success = $true

    #region EmailParameters
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailFrom" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailTo" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailCC" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailBCC" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailServer" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailServerPassword" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailServerPort" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailServerLogin" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailServerEnableSSL" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailEncoding" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailSubject" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailPriority" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $EmailParameters "EmailParameters" "EmailReplyTo" -DisplayProgress $true)
    #endregion EmailParameters

    #region FormattingParameters
    $Success = $Success -and (Test-Key $FormattingParameters "FormattingParameters" "CompanyBranding" -DisplayProgress $true)
    if (Test-Key $FormattingParameters "FormattingParameters" "CompanyBranding" -DisplayProgress $true) {
        $Success = $Success -and (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Logo" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Inline" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Width" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Height" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Link" -DisplayProgress $true)
    }
    $Success = $Success -and (Test-Key $FormattingParameters "FormattingParameters" "FontFamily" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $FormattingParameters "FormattingParameters" "FontSize" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $FormattingParameters "FormattingParameters" "FontHeadingFamily" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $FormattingParameters "FormattingParameters" "FontHeadingSize" -DisplayProgress $true)
    #endregion FormattingParameters

    #region ReportOptions
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "JustTestPrerequisite" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "OpenAsFile" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "KeepReports" -DisplayProgress $true)
    if (Test-Key $ReportOptions "ReportOptions" "KeepReports" -DisplayProgress $true) {
        if (-not (Test-Path $ReportOptions.KeepReportsPath -PathType Container)) {
            $Success = $false
            Write-Color @script:WriteParameters -Text "[-] ", "Path in configuration of ", "ReportOptions.KeepReportsPath", " doesn't exist." -Color White, White, Red, White
        }
    }
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "RemoveDuplicates" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "DisplayConsole" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions.DisplayConsole "ReportOptions.DisplayConsole" "ShowTime" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions.DisplayConsole "ReportOptions.DisplayConsole" "LogFile" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions.DisplayConsole "ReportOptions.DisplayConsole" "TimeFormat" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "Debug" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions.Debug "ReportOptions.Debug" "DisplayTemplateHTML" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions.Debug "ReportOptions.Debug" "Verbose" -DisplayProgress $true)
    #endregion ReportOptions

    #region Report Definions
    $Success = $Success -and (Test-Key $ReportDefinitions "ReportDefinitions" "ReportsAD" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "Servers" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "UseForwarders" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "ForwardServer" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "ForwardEventLog" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "UseDirectScan" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "Automatic" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "OnlyPDC" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "DC" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.ArchiveProcessing "ReportDefinitions.ReportsAD.ArchiveProcessing" "Use" -DisplayProgress $true)
    if ($ReportDefinitions.ReportsAD.ArchiveProcessing.Use) {
        if (Test-Key $ReportDefinitions.ReportsAD.ArchiveProcessing "ReportDefinitions.ReportsAD.ArchiveProcessing" "Directories" -DisplayProgress $true) {
            foreach ($Folder in $ReportDefinitions.ReportsAD.ArchiveProcessing.Directories.Values) {
                if (-not (Test-Path $Folder -PathType Container)) {
                    $Success = $false
                    Write-Color @script:WriteParameters -Text "[-] ", "Path in configuration of ", "ReportDefinitions.ReportsAD.ArchiveProcessing.Directories", " doesn't exist." -Color White, White, Red, White
                }
            }
        }
        if (Test-Key $ReportDefinitions.ReportsAD.ArchiveProcessing "ReportDefinitions.ReportsAD.ArchiveProcessing" "Files" -DisplayProgress $true) {
            foreach ($File in $ReportDefinitions.ReportsAD.ArchiveProcessing.Files.Values) {
                if (-not (Test-Path $File -PathType Leaf)) {
                    $Success = $false
                    Write-Color @script:WriteParameters -Text "[-] ", "Path in configuration of ", "ReportDefinitions.ReportsAD.ArchiveProcessing.Files", " doesn't exist." -Color White, White, Red, White
                }
            }
        }
    }
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "EventBased" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.EventBased "ReportDefinitions.ReportsAD.EventBased" "UserChanges" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "Enabled" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "Events" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "LogName" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "IgnoreWords" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "Custom" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "EventLogSize" -DisplayProgress $true)
    if (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "EventLogSize" -DisplayProgress $true) {
        $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "Enabled" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "Logs" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "SortBy" -DisplayProgress $true)
    }
    #endregion Report Definions

    #region ReportOptions Per Hour
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "PastHour" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "CurrentHour" -DisplayProgress $true)
    #endregion ReportTimes Per Hour

    #region ReportTimes Per Day
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "PastDay" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "CurrentDay" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "OnDay" -DisplayProgress $true)
    if (Test-Key $ReportTimes "ReportTimes" "OnDay" -DisplayProgress $true) {
        $Success = $Success -and (Test-Key $ReportTimes.OnDay "ReportTimes.OnDay" "Enabled" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportTimes.OnDay "ReportTimes.OnDay" "Days" -DisplayProgress $true)
    }
    #endregion ReportTimes Per Day

    #region ReportTimes Per Month
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "PastMonth" -DisplayProgress $true)
    if (Test-Key $ReportTimes "ReportTimes" "PastMonth" -DisplayProgress $true) {
        $Success = $Success -and (Test-Key $ReportTimes.PastMonth "ReportTimes.PastMonth" "Enabled" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportTimes.PastMonth "ReportTimes.PastMonth" "Force" -DisplayProgress $true)
    }
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "CurrentMonth" -DisplayProgress $true)
    #endregion ReportTimes Per Month

    #region ReportTimes Per Quarter
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "PastQuarter" -DisplayProgress $true)
    if (Test-Key $ReportTimes "ReportTimes" "PastQuarter" -DisplayProgress $true) {
        $Success = $Success -and (Test-Key $ReportTimes.PastQuarter "ReportTimes.PastQuarter" "Enabled" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportTimes.PastQuarter "ReportTimes.PastQuarter" "Force" -DisplayProgress $true)
    }
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "CurrentQuarter" -DisplayProgress $true)
    #endregion ReportTimes Per Quarter

    #region ReportTimes Custom Dates
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinusDayX" -DisplayProgress $true)
    if (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinusDayX" -DisplayProgress $true) {
        $Success = $Success -and (Test-Key $ReportTimes.CurrentDayMinusDayX "ReportTimes.CurrentDayMinusDayX" "Enabled" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportTimes.CurrentDayMinusDayX "ReportTimes.CurrentDayMinusDayX" "Days" -DisplayProgress $true)
    }
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinuxDaysX" -DisplayProgress $true)
    if (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinuxDaysX" -DisplayProgress $true) {
        $Success = $Success -and (Test-Key $ReportTimes.CurrentDayMinuxDaysX "ReportTimes.CurrentDayMinuxDaysX" "Enabled" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportTimes.CurrentDayMinuxDaysX "ReportTimes.CurrentDayMinuxDaysX" "Days" -DisplayProgress $true)
    }
    $Success = $Success -and (Test-Key $ReportTimes "ReportTimes" "CustomDate" -DisplayProgress $true)
    if (Test-Key $ReportTimes "ReportTimes" "CustomDate" -DisplayProgress $true) {
        $Success = $Success -and (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "Enabled" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "DateFrom" -DisplayProgress $true)
        $Success = $Success -and (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "DateTo" -DisplayProgress $true)
    }
    #endregion ReportTimes Custom Dates

    #region ReportOptions Options
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "KeepReportsPath" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress $true)
    $Success = $Success -and (Test-Key $ReportOptions "ReportOptions" "RemoveDuplicates" -DisplayProgress $true)
    #endregion ReportOptions Options

    return $Success
}
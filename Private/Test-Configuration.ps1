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
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailFrom" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailTo" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailCC" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailBCC" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServer" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServerPassword" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServerPort" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServerLogin" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServerEnableSSL" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailEncoding" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailSubject" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailPriority" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailReplyTo" -DisplayProgress $true) -and $Success
    #endregion EmailParameters

    #region FormattingParameters
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "CompanyBranding" -DisplayProgress $true) -and $Success
    if (Test-Key $FormattingParameters "FormattingParameters" "CompanyBranding" -DisplayProgress $false) {
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Logo" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Inline" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Width" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Height" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Link" -DisplayProgress $true) -and $Success
    }
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "FontFamily" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "FontSize" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "FontHeadingFamily" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "FontHeadingSize" -DisplayProgress $true) -and $Success
    #endregion FormattingParameters

    #region ReportOptions
    $Success = (Test-Key $ReportOptions "ReportOptions" "JustTestPrerequisite" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "OpenAsFile" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "KeepReports" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportOptions "ReportOptions" "KeepReports" -DisplayProgress $false) {
        if (-not (Test-Path $ReportOptions.KeepReportsPath -PathType Container)) {
            $Success = $false
            Write-Color @script:WriteParameters -Text "[-] ", "Path in configuration of ", "ReportOptions.KeepReportsPath", " doesn't exist." -Color White, White, Red, White
        }
    }
    $Success = (Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "RemoveDuplicates" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "DisplayConsole" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions.DisplayConsole "ReportOptions.DisplayConsole" "ShowTime" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions.DisplayConsole "ReportOptions.DisplayConsole" "LogFile" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions.DisplayConsole "ReportOptions.DisplayConsole" "TimeFormat" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "Debug" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions.Debug "ReportOptions.Debug" "DisplayTemplateHTML" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions.Debug "ReportOptions.Debug" "Verbose" -DisplayProgress $true) -and $Success
    if ($ReportOptions.Contains("AsSql")) {
        $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "Use" -DisplayProgress $true) -and $Success
        if ($ReportOptions.AsSql.Contains("Use") -and $ReportOptions.AsSql.Use) {
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlServer" -DisplayProgress $true) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlDatabase" -DisplayProgress $true) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTable" -DisplayProgress $true) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTableCreate" -DisplayProgress $true) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTableAlterIfNeeded" -DisplayProgress $true) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlCheckBeforeInsert" -DisplayProgress $true) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTableMapping" -DisplayProgress $true) -and $Success
            if (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTableMapping" -DisplayProgress $false) {
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Event ID" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Who" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "When" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Record ID" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Domain Controller" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Action" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Group Name" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "User Affected" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Member Name" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Computer Lockout On" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Reported By" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "SamAccountName" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Display Name" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "UserPrincipalName" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Home Directory" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Home Path" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Script Path" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Profile Path" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "User Workstation" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Password Last Set" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Account Expires" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Primary Group Id" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Allowed To Delegate To" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Old Uac Value" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "New Uac Value" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "User Account Control" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "User Parameters" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Sid History" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Logon Hours" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "OperationType" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Message" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Backup Path" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Log Type" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "AddedWhen" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "AddedWho" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Gathered From" -DisplayProgress $true) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Gathered LogName" -DisplayProgress $true) -and $Success
            }
        }
    }
    #endregion ReportOptions

    #region Report Definions
    $Success = (Test-Key $ReportDefinitions "ReportDefinitions" "ReportsAD" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "Servers" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "UseForwarders" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "ForwardServer" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "ForwardEventLog" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "UseDirectScan" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "Automatic" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "OnlyPDC" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "DC" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.ArchiveProcessing "ReportDefinitions.ReportsAD.ArchiveProcessing" "Use" -DisplayProgress $true) -and $Success
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
    $Success = (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "EventBased" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased "ReportDefinitions.ReportsAD.EventBased" "UserChanges" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "Enabled" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "Events" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "LogName" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "IgnoreWords" -DisplayProgress $true) -and $Success

    $Success = (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "Custom" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "EventLogSize" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "EventLogSize" -DisplayProgress $false) {
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "Enabled" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "Logs" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "SortBy" -DisplayProgress $true) -and $Success
    }
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "ServersData" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "ServersData" -DisplayProgress $false) {
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.ServersData "ReportDefinitions.ReportsAD.Custom.ServersData" "Enabled" -DisplayProgress $true) -and $Success
    }
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "FilesData" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "FilesData" -DisplayProgress $false) {
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.ServersData "ReportDefinitions.ReportsAD.Custom.FilesData" "Enabled" -DisplayProgress $true) -and $Success
    }
    #endregion Report Definions

    #region ReportOptions Per Hour
    $Success = (Test-Key $ReportTimes "ReportTimes" "PastHour" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentHour" -DisplayProgress $true) -and $Success
    #endregion ReportTimes Per Hour

    #region ReportTimes Per Day
    $Success = (Test-Key $ReportTimes "ReportTimes" "PastDay" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentDay" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportTimes "ReportTimes" "OnDay" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "OnDay" -DisplayProgress $false) {
        $Success = (Test-Key $ReportTimes.OnDay "ReportTimes.OnDay" "Enabled" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportTimes.OnDay "ReportTimes.OnDay" "Days" -DisplayProgress $true) -and $Success
    }
    #endregion ReportTimes Per Day

    #region ReportTimes Per Month
    $Success = (Test-Key $ReportTimes "ReportTimes" "PastMonth" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "PastMonth" -DisplayProgress $false) {
        $Success = (Test-Key $ReportTimes.PastMonth "ReportTimes.PastMonth" "Enabled" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportTimes.PastMonth "ReportTimes.PastMonth" "Force" -DisplayProgress $true) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentMonth" -DisplayProgress $true) -and $Success
    #endregion ReportTimes Per Month

    #region ReportTimes Per Quarter
    $Success = (Test-Key $ReportTimes "ReportTimes" "PastQuarter" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "PastQuarter" -DisplayProgress $false) {
        $Success = (Test-Key $ReportTimes.PastQuarter "ReportTimes.PastQuarter" "Enabled" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportTimes.PastQuarter "ReportTimes.PastQuarter" "Force" -DisplayProgress $true) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentQuarter" -DisplayProgress $true) -and $Success
    #endregion ReportTimes Per Quarter

    #region ReportTimes Custom Dates
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinusDayX" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinusDayX" -DisplayProgress $false) {
        $Success = (Test-Key $ReportTimes.CurrentDayMinusDayX "ReportTimes.CurrentDayMinusDayX" "Enabled" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportTimes.CurrentDayMinusDayX "ReportTimes.CurrentDayMinusDayX" "Days" -DisplayProgress $true) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinuxDaysX" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinuxDaysX" -DisplayProgress $false) {
        $Success = (Test-Key $ReportTimes.CurrentDayMinuxDaysX "ReportTimes.CurrentDayMinuxDaysX" "Enabled" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportTimes.CurrentDayMinuxDaysX "ReportTimes.CurrentDayMinuxDaysX" "Days" -DisplayProgress $true) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CustomDate" -DisplayProgress $true) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "CustomDate" -DisplayProgress $false) {
        $Success = (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "Enabled" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "DateFrom" -DisplayProgress $true) -and $Success
        $Success = (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "DateTo" -DisplayProgress $true) -and $Success
    }
    #endregion ReportTimes Custom Dates

    #region ReportOptions Options
    $Success = (Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "KeepReportsPath" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress $true) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "RemoveDuplicates" -DisplayProgress $true) -and $Success
    #endregion ReportOptions Options

    return $Success
}
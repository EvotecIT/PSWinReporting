function Test-Configuration () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$LoggerParameters,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$EmailParameters,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$FormattingParameters,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$ReportOptions,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$ReportTimes,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$ReportDefinitions
    )
    $Logger.AddInfoRecord('Testing for configuration consistency. This is to make sure the script can be safely executed.')
    # Configuration successful check flag
    $Success = $true

    #region EmailParameters
    $Success = (Test-Key $LoggerParameters "LoggerParameters" "ShowTime" -DisplayProgress) -and $Success
    $Success = (Test-Key $LoggerParameters "LoggerParameters" "LogsDir" -DisplayProgress) -and $Success
    $Success = (Test-Key $LoggerParameters "LoggerParameters" "TimeFormat" -DisplayProgress) -and $Success
    #endregion EmailParameters

    #region EmailParameters
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailFrom" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailTo" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailCC" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailBCC" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServer" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServerPassword" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServerPort" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServerLogin" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailServerEnableSSL" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailEncoding" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailSubject" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailPriority" -DisplayProgress) -and $Success
    $Success = (Test-Key $EmailParameters "EmailParameters" "EmailReplyTo" -DisplayProgress) -and $Success
    #endregion EmailParameters

    #region FormattingParameters
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "CompanyBranding" -DisplayProgress) -and $Success
    if (Test-Key $FormattingParameters "FormattingParameters" "CompanyBranding" ) {
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Logo" -DisplayProgress) -and $Success
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Inline" -DisplayProgress) -and $Success
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Width" -DisplayProgress) -and $Success
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Height" -DisplayProgress) -and $Success
        $Success = (Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Link" -DisplayProgress) -and $Success
    }
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "FontFamily" -DisplayProgress) -and $Success
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "FontSize" -DisplayProgress) -and $Success
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "FontHeadingFamily" -DisplayProgress) -and $Success
    $Success = (Test-Key $FormattingParameters "FormattingParameters" "FontHeadingSize" -DisplayProgress) -and $Success
    #endregion FormattingParameters

    #region ReportOptions
    $Success = (Test-Key $ReportOptions "ReportOptions" "JustTestPrerequisite" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress) -and $Success
    #$Success = (Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress) -and $Success

    $Success = (Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress) -and $Success
    if (Test-Key $ReportOptions "ReportOptions" "AsHTML" ) {
        $Success = (Test-Key $ReportOptions.AsHTML "ReportOptions.AsHTML" "Use" -DisplayProgress -ValueType 'Boolean') -and $Success
        $Success = (Test-Key $ReportOptions.AsHTML "ReportOptions.ASHTML" "OpenAsFile" -DisplayProgress -ValueType 'Boolean') -and $Success
    }

    $Success = (Test-Key $ReportOptions "ReportOptions" "AsDynamicHTML" -DisplayProgress) -and $Success
    if (Test-Key $ReportOptions "ReportOptions" "AsDynamicHTML" ) {
        $Success = (Test-Key $ReportOptions.AsDynamicHTML "ReportOptions.AsDynamicHTML" "Use" -DisplayProgress -ValueType 'Boolean') -and $Success
        $Success = (Test-Key $ReportOptions.AsDynamicHTML "ReportOptions.AsDynamicHTML" "OpenAsFile" -DisplayProgress -ValueType 'Boolean') -and $Success
        $Success = (Test-Key $ReportOptions.AsDynamicHTML "ReportOptions.AsDynamicHTML" "Title" -DisplayProgress -ValueType 'string') -and $Success
        $Success = (Test-Key $ReportOptions.AsDynamicHTML "ReportOptions.AsDynamicHTML" "Path" -DisplayProgress -ValueType 'string') -and $Success
        $Success = (Test-Key $ReportOptions.AsDynamicHTML "ReportOptions.AsDynamicHTML" "FilePattern" -DisplayProgress -ValueType 'string') -and $Success
        $Success = (Test-Key $ReportOptions.AsDynamicHTML "ReportOptions.AsDynamicHTML" "DateFormat" -DisplayProgress -ValueType 'string') -and $Success
        $Success = (Test-Key $ReportOptions.AsDynamicHTML "ReportOptions.AsDynamicHTML" "EmbedCSS" -DisplayProgress -ValueType 'Boolean') -and $Success
        $Success = (Test-Key $ReportOptions.AsDynamicHTML "ReportOptions.AsDynamicHTML" "EmbedJS" -DisplayProgress -ValueType 'Boolean') -and $Success

    }





    $Success = (Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress) -and $Success

    $Success = (Test-Key $ReportOptions "ReportOptions" "KeepReports" -DisplayProgress) -and $Success
    if (Test-Key $ReportOptions "ReportOptions" "KeepReports" ) {
        if (-not (Test-Path $ReportOptions.KeepReportsPath -PathType Container)) {
            $Success = $false
            $Logger.AddErrorRecord('Path in configuration of ReportOptions.KeepReportsPath doesn''t exist.')
        }
    }
    $Success = (Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "RemoveDuplicates" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportOptions "ReportOptions" "Debug" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportOptions.Debug "ReportOptions.Debug" "DisplayTemplateHTML" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportOptions.Debug "ReportOptions.Debug" "Verbose" -DisplayProgress) -and $Success
    if ($ReportOptions.Contains("AsSql")) {
        $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "Use" -DisplayProgress) -and $Success
        if ($ReportOptions.AsSql.Contains("Use") -and $ReportOptions.AsSql.Use) {
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlServer" -DisplayProgress) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlDatabase" -DisplayProgress) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTable" -DisplayProgress) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTableCreate" -DisplayProgress) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTableAlterIfNeeded" -DisplayProgress) -and $Success
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlCheckBeforeInsert" -DisplayProgress) -and $Success
            <# This is not required to exists. Only if SQL is needed, used.
            $Success = (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTableMapping" -DisplayProgress) -and $Success
            if (Test-Key $ReportOptions.AsSql "ReportOptions.AsSql" "SqlTableMapping" ) {
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Event ID" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Who" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "When" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Record ID" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Domain Controller" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Action" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Group Name" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "User Affected" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Member Name" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Computer Lockout On" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Reported By" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "SamAccountName" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Display Name" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "UserPrincipalName" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Home Directory" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Home Path" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Script Path" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Profile Path" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "User Workstation" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Password Last Set" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Account Expires" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Primary Group Id" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Allowed To Delegate To" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Old Uac Value" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "New Uac Value" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "User Account Control" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "User Parameters" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Sid History" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Logon Hours" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "OperationType" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Message" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Backup Path" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Log Type" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "AddedWhen" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "AddedWho" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Gathered From" -DisplayProgress) -and $Success
                $Success = (Test-Key $ReportOptions.AsSql.SqlTableMapping "ReportOptions.SqlTableMapping" "Gathered LogName" -DisplayProgress) -and $Success
            }
            #>
        }
    }
    #endregion ReportOptions

    #region Report Definions
    $Success = (Test-Key $ReportDefinitions "ReportDefinitions" "ReportsAD" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "Servers" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "UseForwarders" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "ForwardServer" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "ForwardEventLog" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "UseDirectScan" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "Automatic" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "OnlyPDC" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "DC" -DisplayProgress) -and $Success
    if (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "ArchiveProcessing") {
        if (Test-Key $ReportDefinitions.ReportsAD.ArchiveProcessing "ReportDefinitions.ReportsAD.ArchiveProcessing" "Directories" -DisplayProgress) {
            foreach ($Folder in $ReportDefinitions.ReportsAD.ArchiveProcessing.Directories.Values) {
                if (-not (Test-Path $Folder -PathType Container)) {
                    $Success = $false
                    $Logger.AddErrorRecord('Path in configuration of ReportDefinitions.ReportsAD.ArchiveProcessing.Directories doesn''t exist.')
                }
            }
        }
        if (Test-Key $ReportDefinitions.ReportsAD.ArchiveProcessing "ReportDefinitions.ReportsAD.ArchiveProcessing" "Files" -DisplayProgress) {
            foreach ($File in $ReportDefinitions.ReportsAD.ArchiveProcessing.Files.Values) {
                if (-not (Test-Path $File -PathType Leaf)) {
                    $Success = $false
                    $Logger.AddErrorRecord('Path in configuration of ReportDefinitions.ReportsAD.ArchiveProcessing.Files doesn''t exist.')
                }
            }
        }
    }
    $Success = (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "EventBased" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased "ReportDefinitions.ReportsAD.EventBased" "UserChanges" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "Enabled" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "Events" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "LogName" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "IgnoreWords" -DisplayProgress) -and $Success

    $Success = (Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "Custom" -DisplayProgress) -and $Success
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "EventLogSize" -DisplayProgress) -and $Success
    if (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "EventLogSize" ) {
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "Enabled" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "Logs" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "SortBy" -DisplayProgress) -and $Success
    }
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "ServersData" -DisplayProgress) -and $Success
    if (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "ServersData" ) {
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.ServersData "ReportDefinitions.ReportsAD.Custom.ServersData" "Enabled" -DisplayProgress) -and $Success
    }
    $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "FilesData" -DisplayProgress) -and $Success
    if (Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "FilesData" ) {
        $Success = (Test-Key $ReportDefinitions.ReportsAD.Custom.ServersData "ReportDefinitions.ReportsAD.Custom.FilesData" "Enabled" -DisplayProgress) -and $Success
    }
    #endregion Report Definions

    #region ReportOptions Per Hour
    $Success = (Test-Key $ReportTimes "ReportTimes" "PastHour" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "PastHour" ) {
        $Success = (Test-Key $ReportTimes.PastHour "ReportTimes.PastHour" "Enabled" -DisplayProgress -ValueType 'Boolean') -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentHour" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "CurrentHour" ) {
        $Success = (Test-Key $ReportTimes.CurrentHour "ReportTimes.CurrentHour" "Enabled" -DisplayProgress -ValueType 'Boolean') -and $Success
    }
    #endregion ReportTimes Per Hour

    #region ReportTimes Per Day
    $Success = (Test-Key $ReportTimes "ReportTimes" "PastDay" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "PastDay" ) {
        $Success = (Test-Key $ReportTimes.PastDay "ReportTimes.PastDay" "Enabled" -DisplayProgress -ValueType 'Boolean') -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentDay" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "CurrentDay" ) {
        $Success = (Test-Key $ReportTimes.CurrentDay "ReportTimes.CurrentDay" "Enabled" -DisplayProgress -ValueType 'Boolean') -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "OnDay" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "OnDay" ) {
        $Success = (Test-Key $ReportTimes.OnDay "ReportTimes.OnDay" "Enabled" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportTimes.OnDay "ReportTimes.OnDay" "Days" -DisplayProgress) -and $Success
    }
    #endregion ReportTimes Per Day

    #region ReportTimes Per Month
    $Success = (Test-Key $ReportTimes "ReportTimes" "PastMonth" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "PastMonth" ) {
        $Success = (Test-Key $ReportTimes.PastMonth "ReportTimes.PastMonth" "Enabled" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportTimes.PastMonth "ReportTimes.PastMonth" "Force" -DisplayProgress) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentMonth" -DisplayProgress) -and $Success
    #endregion ReportTimes Per Month

    #region ReportTimes Per Quarter
    $Success = (Test-Key $ReportTimes "ReportTimes" "PastQuarter" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "PastQuarter" ) {
        $Success = (Test-Key $ReportTimes.PastQuarter "ReportTimes.PastQuarter" "Enabled" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportTimes.PastQuarter "ReportTimes.PastQuarter" "Force" -DisplayProgress) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentQuarter" -DisplayProgress) -and $Success
    #endregion ReportTimes Per Quarter

    #region ReportTimes Custom Dates
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinusDayX" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinusDayX" ) {
        $Success = (Test-Key $ReportTimes.CurrentDayMinusDayX "ReportTimes.CurrentDayMinusDayX" "Enabled" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportTimes.CurrentDayMinusDayX "ReportTimes.CurrentDayMinusDayX" "Days" -DisplayProgress) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinuxDaysX" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "CurrentDayMinuxDaysX" ) {
        $Success = (Test-Key $ReportTimes.CurrentDayMinuxDaysX "ReportTimes.CurrentDayMinuxDaysX" "Enabled" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportTimes.CurrentDayMinuxDaysX "ReportTimes.CurrentDayMinuxDaysX" "Days" -DisplayProgress) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "CustomDate" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "CustomDate" ) {
        $Success = (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "Enabled" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "DateFrom" -DisplayProgress) -and $Success
        $Success = (Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "DateTo" -DisplayProgress) -and $Success
    }
    $Success = (Test-Key $ReportTimes "ReportTimes" "Everything" -DisplayProgress) -and $Success
    if (Test-Key $ReportTimes "ReportTimes" "Everything" ) {
        $Success = (Test-Key $ReportTimes.PastDay "ReportTimes.Everything" "Enabled" -DisplayProgress -ValueType 'Boolean') -and $Success
    }
    #endregion ReportTimes Custom Dates

    #region ReportOptions Options
    #$Success = (Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress) -and $Success
    #$Success = (Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress) -and $Success
    #$Success = (Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress) -and $Success
    #$Success = (Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress) -and $Success
    #$Success = (Test-Key $ReportOptions "ReportOptions" "KeepReportsPath" -DisplayProgress) -and $Success
    #$Success = (Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress) -and $Success
    #$Success = (Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress) -and $Success
    #$Success = (Test-Key $ReportOptions "ReportOptions" "RemoveDuplicates" -DisplayProgress) -and $Success
    #endregion ReportOptions Options

    return $Success
}
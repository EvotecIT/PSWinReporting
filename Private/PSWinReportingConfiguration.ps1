function Test-ConfigurationReportsAD () {
    $parameter = 'Enabled', 'Events', 'LogName', 'IgnoreWords'

}

function Test-Configuration ($EmailParameters, $FormattingParameters, $ReportOptions, $ReportTimes, $ReportDefinitions) {
    Write-Warning "[i] Testing for configuration consistency. This is to make sure the script can be safely executed..."
    if ($EmailParameters -eq $null -or $ReportOptions -eq $null -or $FormattingParameters -eq $null -or $ReportTimes -eq $null -or $ReportDefinitions -eq $null) {
        Write-Warning "[i] There is not enough parameters passed to the Start-Reporting. Make sure there are 4 parameter groups (hashtables). Check documentation - you would be better to just start from scratch!"
        Exit
    }
    Write-Color @script:WriteParameters -Text "[t] ", "Testing for missing parameters in configuration...", "Keep tight!" -Color White, White, Yellow
    $ConfigurationFormatting = @()
    $ConfigurationReport = @()
    $ConfigurationEmail = @()
    $ConfigurationDefinitions = @()

    #region EmailParameters

    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailFrom" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailTo" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailCC" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailBCC" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServer" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServerPassword" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServerPort" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServerLogin" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServerEnableSSL" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailEncoding" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailSubject" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailPriority" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailReplyTo" -DisplayProgress $true
    #endregion EmailParameters
    #region FormattingParameters
    #  Write-Color @Global:WriteParameters -Text "[t] ", "Testing for missing parameters in configuration of ", "FormattingParameters", "..." -Color White, White, Yellow
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "CompanyBranding" -DisplayProgress $true
    if ($ConfigurationFormatting[ - 1] -eq $true) {
        $ConfigurationFormatting += Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Logo" -DisplayProgress $true
        $ConfigurationFormatting += Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Width" -DisplayProgress $true
        $ConfigurationFormatting += Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Height" -DisplayProgress $true
        $ConfigurationFormatting += Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Link" -DisplayProgress $true
    }
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "FontFamily" -DisplayProgress $true
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "FontSize" -DisplayProgress $true
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "FontHeadingFamily" -DisplayProgress $true
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "FontHeadingSize" -DisplayProgress $true
    #endregion FormattingParameters
    #region Report Definions
    $ConfigurationDefinitions += Test-Key $ReportDefinitions "ReportDefinitions" "ReportsAD" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "Servers" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "Automatic" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "OnlyPDC" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.Servers "ReportDefinitions.ReportsAD.Servers" "DC" -DisplayProgress $true

    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "EventBased" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.EventBased "ReportDefinitions.ReportsAD.EventBased" "UserChanges" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "Enabled" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "Events" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "LogName" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.EventBased.UserChanges "ReportDefinitions.ReportsAD.EventBased.UserChanges" "IgnoreWords" -DisplayProgress $true

    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD "ReportDefinitions.ReportsAD" "Custom" -DisplayProgress $true
    $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.Custom "ReportDefinitions.ReportsAD.Custom" "EventLogSize" -DisplayProgress $true
    if ($ConfigurationDefinitions[ - 1] -eq $true) {
        $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "Enabled" -DisplayProgress $true
        $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "Logs" -DisplayProgress $true
        $ConfigurationDefinitions += Test-Key $ReportDefinitions.ReportsAD.Custom.EventLogSize "ReportDefinitions.ReportsAD.Custom.EventLogSize" "SortBy" -DisplayProgress $true
    }
    #endregion Repor Report Definions

    #region ReportOptions Per Hour
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "PastHour" -DisplayProgress $true
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "CurrentHour" -DisplayProgress $true
    #endregion ReportTimes Per Hour
    #region ReportTimes Per Day
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "PastDay" -DisplayProgress $true
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "CurrentDay" -DisplayProgress $true
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "OnDay" -DisplayProgress $true
    if ($ConfigurationReportTimes[ - 1] -eq $true) {
        $ConfigurationReportTimes += Test-Key $ReportTimes.OnDay "ReportTimes.OnDay" "Enabled" -DisplayProgress $true
        $ConfigurationReportTimes += Test-Key $ReportTimes.OnDay "ReportTimes.OnDay" "Days" -DisplayProgress $true
    }
    #region ReportTimes Per Month
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "PastMonth" -DisplayProgress $true
    if ($ConfigurationReportTimes[ - 1] -eq $true) {
        $ConfigurationReportTimes += Test-Key $ReportTimes.PastMonth "ReportTimes.PastMonth" "Enabled" -DisplayProgress $true
        $ConfigurationReportTimes += Test-Key $ReportTimes.PastMonth "ReportTimes.PastMonth" "Force" -DisplayProgress $true
    }
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "CurrentMonth" -DisplayProgress $true
    #endregion ReportTimes Per Month
    #region ReportTimes Per Quarter

    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "PastQuarter" -DisplayProgress $true
    if ($ConfigurationReportTimes[ - 1] -eq $true) {
        $ConfigurationReportTimes += Test-Key $ReportTimes.PastQuarter "ReportTimes.PastQuarter" "Enabled" -DisplayProgress $true
        $ConfigurationReportTimes += Test-Key $ReportTimes.PastQuarter "ReportTimes.PastQuarter" "Force" -DisplayProgress $true
    }
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "CurrentQuarter" -DisplayProgress $true
    #endregion ReportTimes Per Quarter
    #region ReportTimes Custom Dates
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "CurrentDayMinusDayX" -DisplayProgress $true
    if ($ConfigurationReportTimes[ - 1] -eq $true) {
        $ConfigurationReportTimes += Test-Key $ReportTimes.CurrentDayMinusDayX "ReportTimes.CurrentDayMinusDayX" "Enabled" -DisplayProgress $true
        $ConfigurationReportTimes += Test-Key $ReportTimes.CurrentDayMinusDayX "ReportTimes.CurrentDayMinusDayX" "Days" -DisplayProgress $true
    }
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "CurrentDayMinuxDaysX" -DisplayProgress $true
    if ($ConfigurationReportTimes[ - 1] -eq $true) {
        $ConfigurationReportTimes += Test-Key $ReportTimes.CurrentDayMinuxDaysX "ReportTimes.CurrentDayMinuxDaysX" "Enabled" -DisplayProgress $true
        $ConfigConfigurationReportTimesurationReport += Test-Key $ReportTimes.CurrentDayMinuxDaysX "ReportTimes.CurrentDayMinuxDaysX" "Days" -DisplayProgress $true
    }
    $ConfigurationReportTimes += Test-Key $ReportTimes "ReportTimes" "CustomDate" -DisplayProgress $true
    if ($ConfigurationReportTimes[ - 1] -eq $true) {
        $ConfigurationReportTimes += Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "Enabled" -DisplayProgress $true
        $ConfigurationReportTimes += Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "DateFrom" -DisplayProgress $true
        $ConfigurationReportTimes += Test-Key $ReportTimes.CustomDate "ReportTimes.CustomDate" "DateTo" -DisplayProgress $true
    }
    #endregion ReportTimes Custom Dates

    #region ReportOptions Options
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "KeepReportsPath" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress $true
    #endregion ReportOptions Options
    if ($ConfigurationFormatting -notcontains $false -and
        $ConfigurationReport -notcontains $false -and
        $ConfigurationEmail -notcontains $false -and
        $ConfigurationDefinitions -notcontains $false -and
        $ConfigurationReportTimes -notcontains $false) {
        return $true
    } else {
        return $false
    }
}
Function Test-Prerequisite () {
    param (
        [hashtable] $EmailParameters,
        [hashtable] $FormattingParameters,
        [hashtable] $ReportOptions,
        [hashtable] $ReportTimes,
        [hashtable] $ReportDefinitions
    )
    $Configuration = Test-Configuration $EmailParameters $FormattingParameters $ReportOptions $ReportTimes $ReportDefinitions
    if (-not $Configuration) {
        Write-Color @script:WriteParameters "[i] ", "There are parameters missing in configuration file. Can't continue running...", "Terminated!" -Color White, Yellow, Red
        Exit
    }

    Write-Color @script:WriteParameters "[i] ", "Testing for prerequisite availability..." -Color White, Yellow
    $ImportPSEventViewer = Get-ModulesAvailability -Name "PSEventViewer"
    If ($ImportPSEventViewer -eq $true) {
        Write-Color @script:WriteParameters  "[+] ", "PSEventViewer", " module imported. Continuing..." -Color White, Green, White
    } else {
        Write-Color @script:WriteParameters  "[-] ", "PSEventViewer", " module not found." -Color White, Red, White
    }

    $ImportPSADReporting = Get-ModulesAvailability -Name "PSWinReporting"
    If ($ImportPSADReporting -eq $true) {
        Write-Color @script:WriteParameters  "[+] ", "PSWinReporting", " module imported. Continuing..." -Color White, Green, White
    } else {
        Write-Color @script:WriteParameters  "[-] ", "PSWinReporting", " module not found." -Color White, Red, White
    }

    $ImportExcel = Get-ModulesAvailability -Name "ImportExcel"
    if ($ImportExcel -eq $true) {
        Write-Color @script:WriteParameters  "[+] ", "ImportExcel", " module imported. Continuing..." -Color White, Green, White
    } else {
        Write-Color @script:WriteParameters  "[-] ", "ImportExcel", " module not found." -Color White, Red, White
        if ($ReportOptions.AsExcel -eq $true) {
            Write-Color @script:WriteParameters  "[-] ", "ImportExcel ", "module is not installed. Disable ", "AsExcel", " under ", "ReportOptions", " option before rerunning this script." -Color White, Red, White, Yellow, White, Yellow, White
            Write-Color @script:WriteParameters  "[-] ", "Alternatively run ", "Install-Module -Name ImportExcel", " before re-running this script. It's quite useful module!" -Color White, White, Yellow, White
            Write-Color @script:WriteParameters  "[-] ", "If ", "Install-Module", " is not there as well (", "poor you - running older system are you?", ") you need to download PackageManagement PowerShell Modules." -Color White, White, Yellow, White, Yellow, White
            Write-Color @script:WriteParameters  "[-] ", "It can be found at ", "https://www.microsoft.com/en-us/download/details.aspx?id=51451", ". After download, install and re-run Install-Module again." -Color White, White, Yellow, White
        }
    }
    $ImportActiveDirectory = Get-ModulesAvailability -Name "ActiveDirectory"
    if ($ImportActiveDirectory -eq $true) {
        Write-Color @script:WriteParameters  "[+] ", "ActiveDirectory", " module imported. Continuing..." -Color White, Green, White
    } else {
        Write-Color @script:WriteParameters  "[-] ", "ActiveDirectory", " module not found." -Color White, Red, White
        Write-Color @script:WriteParameters  "[-] ", "ActiveDirectory", " module is ", "critical", " for operation of this script." -Color White, Red, White, Red, White
        Write-Color @script:WriteParameters  "[-] ", "Please make sure it's available on the machine before running this script" -Color White, Red
    }
    try {
        $TestActiveDirectory = get-addomain
        $AdIsAvailable = $true
    } catch {
        if ($_.Exception -match "Unable to find a default server with Active Directory Web Services running.") {
            Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
        }
        Write-Color @script:WriteParameters "[-] ", "Error: $($_.Exception.Message)" -Color White, Red
        $AdIsAvailable = $false
    }

    if ($ImportPSEventViewer -eq $true -and $ImportPSADReporting -eq $true -and $ImportActiveDirectory -eq $true -and (($ReportOptions.AsExcel -eq $true -and $ImportExcel -eq $true) -or $ReportOptions.AsExcel -eq $false) -and $AdIsAvailable -eq $true) {
        return #$true
    } else {
        Exit
        #return $false
    }
}
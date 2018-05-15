function Test-Configuration ($EmailParameters, $ReportOptions, $FormattingParameters) {
    Write-Warning "[i] Testing for configuration consistency. This is to make sure the script can be safely executed..."
    if ($EmailParameters -eq $null -or $ReportOptions -eq $null -or $FormattingParameters -eq $null) {
        Write-Warning "[i] There is not enough parameters passed to the Start-Reporting. Make sure there are 4 parameter groups (hashtables). Check documentation - you would be better to just start from scratch!"
        Exit
    }
    Write-Color @script:WriteParameters -Text "[t] ", "Testing for missing parameters in configuration...", "Keep tight!" -Color White, White, Yellow
    $ConfigurationFormatting = @()
    $ConfigurationReport = @()
    $ConfigurationEmail = @()

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
    #region ReportOptions Reports
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "OnlyPrimaryDC" -DisplayProgress $true

    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeDomainControllers" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeClearedLogs"    -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeGroupEvents" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeUserEvents" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeUserStatuses" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeUserLockouts" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeDomainControllersReboots" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeLogonEvents" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeGroupPolicyChanges" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeGroupCreateDelete" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeTimeToGenerate" -DisplayProgress $true

    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeEventLogSize" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.IncludeEventLogSize "ReportOptions.IncludeEventLogSize" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.IncludeEventLogSize "ReportOptions.IncludeEventLogSize" "Logs" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.IncludeEventLogSize "ReportOptions.IncludeEventLogSize" "SortBy" -DisplayProgress $true
    }
    #endregion ReportOptions Reports

    #region ReportOptions Per Hour
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportPastHour" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentHour" -DisplayProgress $true
    #endregion ReportOptions Per Hour
    #region ReportOptions Per Day
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportPastDay" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentDay" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportOnDay" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportOnDay "ReportOptions.ReportOnDay" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportOnDay "ReportOptions.ReportOnDay" "Days" -DisplayProgress $true
    }
    #region ReportOptions Per Month
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportPastMonth" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportPastMonth "ReportOptions.ReportPastMonth" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportPastMonth "ReportOptions.ReportPastMonth" "Force" -DisplayProgress $true
    }
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentMonth" -DisplayProgress $true
    #endregion ReportOptions Per Month
    #region ReportOptions Per Quarter

    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportPastQuarter" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportPastQuarter "ReportOptions.ReportPastQuarter" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportPastQuarter "ReportOptions.ReportPastQuarter" "Force" -DisplayProgress $true
    }
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentQuarter" -DisplayProgress $true
    #endregion ReportOptions Per Quarter
    #region ReportOptions Custom Dates
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentDayMinusDayX" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportCurrentDayMinusDayX "ReportOptions.ReportCurrentDayMinusDayX" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportCurrentDayMinusDayX "ReportOptions.ReportCurrentDayMinusDayX" "Days" -DisplayProgress $true
    }
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentDayMinuxDaysX" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportCurrentDayMinuxDaysX "ReportOptions.ReportCurrentDayMinuxDaysX" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportCurrentDayMinuxDaysX "ReportOptions.ReportCurrentDayMinuxDaysX" "Days" -DisplayProgress $true
    }
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCustomDate" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportCustomDate "ReportOptions.ReportCustomDate" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportCustomDate "ReportOptions.ReportCustomDate" "DateFrom" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportCustomDate "ReportOptions.ReportCustomDate" "DateTo" -DisplayProgress $true
    }
    #endregion ReportOptions Custom Dates

    #region ReportOptions Options
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "KeepReportsPath" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress $true
    #endregion ReportOptions Options
    if ($ConfigurationFormatting -notcontains $false -and $ConfigurationReport -notcontains $false -and $ConfigurationEmail -notcontains $false) {
        return $true
    } else {
        return $false
    }
}
Function Test-Prerequisite ([hashtable] $EmailParameters, [hashtable] $ReportOptions, [hashtable]  $FormattingParameters) {
    $Configuration = Test-Configuration $EmailParameters $ReportOptions $FormattingParameters
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
function Start-Report {
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $Dates,
        [System.Collections.IDictionary] $EmailParameters,
        [System.Collections.IDictionary] $FormattingParameters,
        [System.Collections.IDictionary] $ReportOptions,
        [System.Collections.IDictionary] $ReportDefinitions
    )

    $time = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
    # Declare variables
    $EventLogTable = @()
    $TableEventLogFiles = @()

    $Logger.AddInfoRecord("Processing report for dates from: $($Dates.DateFrom) to $($Dates.DateTo)")
    $Logger.AddInfoRecord('Establishing servers list to process...')

    $ServersAD = Get-DC
    $Servers = Find-ServersAD -ReportDefinitions $ReportDefinitions -DC $ServersAD

    $Logger.AddInfoRecord('Preparing Security Events list to be processed')
    $EventsToProcessSecurity = Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch 'Security'
    $Logger.AddInfoRecord('Preparing System Events list to be processed')
    $EventsToProcessSystem = Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch 'System'

    # Summary of events to process
    $Logger.AddInfoRecord("Found security events to process: $($EventsToProcessSecurity -join ', ')")
    $Logger.AddInfoRecord("Found system events to process: $($EventsToProcessSystem -join ', ')")

    $Events = New-ArrayList
    if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
        $Logger.AddInfoRecord("Preparing Forwarded Events on forwarding servers: $($ReportDefinitions.ReportsAD.Servers.ForwardServer -join ', ')")
        foreach ($ForwardedServer in $ReportDefinitions.ReportsAD.Servers.ForwardServer) {
            #$Events += Get-Events -Server $ReportDefinitions.ReportsAD.ForwardServer -LogName $ReportDefinitions.ReportsAD.ForwardServer.ForwardEventLog
            $FoundEvents = Get-AllRequiredEvents -Servers $ForwardedServer -Dates $Dates -Events $EventsToProcessSecurity -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
            Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
            $FoundEvents = Get-AllRequiredEvents -Servers $ForwardedServer -Dates $Dates -Events $EventsToProcessSystem -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
            Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
        }
    }
    if ($ReportDefinitions.ReportsAD.Servers.UseDirectScan) {
        $Logger.AddInfoRecord("Processing Security Events from directly scanned servers: $($Servers -Join ', ')")
        $FoundEvents = Get-AllRequiredEvents -Servers $Servers -Dates $Dates -Events $EventsToProcessSecurity -LogName 'Security' -Verbose:$ReportOptions.Debug.Verbose
        Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
        $Logger.AddInfoRecord("Processing System Events from directly scanned servers: $($Servers -Join ', ')")
        $FoundEvents = Get-AllRequiredEvents -Servers $Servers -Dates $Dates -Events $EventsToProcessSystem -LogName 'System' -Verbose:$ReportOptions.Debug.Verbose
        Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
    }
    if ($ReportDefinitions.ReportsAD.ArchiveProcessing.Use) {
        $EventLogFiles = Get-CongfigurationEvents -Sections $ReportDefinitions.ReportsAD.ArchiveProcessing
        foreach ($File in $EventLogFiles) {
            $TableEventLogFiles += Get-FileInformation -File $File
            $Logger.AddInfoRecord("Processing Security Events on file: $File")
            $FoundEvents = Get-AllRequiredEvents -FilePath $File -Dates $Dates -Events $EventsToProcessSecurity -LogName 'Security' -Verbose:$ReportOptions.Debug.Verbose
            Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
            $Logger.AddInfoRecord("Processing System Events on file: $File")
            $FoundEvents = Get-AllRequiredEvents -FilePath $File -Dates $Dates -Events $EventsToProcessSystem -LogName 'System' -Verbose:$ReportOptions.Debug.Verbose
            Add-ToArrayAdvanced -List $Events -Element $FoundEvents -SkipNull -Merge
        }
    }



    $Logger.AddInfoRecord('Processing Event Log Sizes on defined servers for warnings')
    $EventLogDatesSummary = @()
    if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
        $Logger.AddInfoRecord("Processing Event Log Sizes on $($ReportDefinitions.ReportsAD.Servers.ForwardServer) for warnings")
        $EventLogDatesSummary += Get-EventLogSize -Servers $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -Verbose:$ReportOptions.Debug.Verbose
    }
    if ($ReportDefinitions.ReportsAD.Servers.UseDirectScan) {
        $Logger.AddInfoRecord("Processing Event Log Sizes on $($Servers -Join ', ') for warnings")
        $EventLogDatesSummary += Get-EventLogSize -Servers $Servers -LogName 'Security'
        $EventLogDatesSummary += Get-EventLogSize -Servers $Servers -LogName 'System'
    }
    $Logger.AddInfoRecord('Verifying Warnings reported earlier')
    $Warnings = Invoke-EventLogVerification -Results $EventLogDatesSummary -Dates $Dates

    if ($ReportOptions.RemoveDuplicates) {
        $Logger.AddInfoRecord("Removing Duplicates from all events. Current list contains $(Get-ObjectCount -Object $Events) events")
        $Events = Remove-DuplicateObjects -Object $Events -Property 'RecordID'
        $Logger.AddInfoRecord("Removed Duplicates Following $(Get-ObjectCount -Object $Events) events will be analyzed further")
    }

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

    if ($ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -eq $true) {

        if ($ReportDefinitions.ReportsAD.Servers.UseForwarders) {
            foreach ($LogName in $ReportDefinitions.ReportsAD.Servers.ForwardEventLog) {
                $Logger.AddInfoRecord("Running Event Log Size Report for $LogName log")
                $EventLogTable += Get-EventLogSize -Servers $ReportDefinitions.ReportsAD.Servers.ForwardServer  -LogName $LogName
                $Logger.AddInfoRecord("Ending Event Log Size Report for $LogName log")
            }
        }
        foreach ($LogName in $ReportDefinitions.ReportsAD.Custom.EventLogSize.Logs) {
            $Logger.AddInfoRecord("Running Event Log Size Report for $LogName log")
            $EventLogTable += Get-EventLogSize -Servers $Servers -LogName $LogName
            $Logger.AddInfoRecord("Ending Event Log Size Report for $LogName log")
        }
        if ($ReportDefinitions.ReportsAD.Custom.EventLogSize.SortBy -ne "") { $EventLogTable = $EventLogTable | Sort-Object $ReportDefinitions.ReportsAD.Custom.EventLogSize.SortBy }

    }

    # Prepare email body
    $Logger.AddInfoRecord('Prepare email head and body')
    $EmailBody = Set-EmailHead -FormattingOptions $FormattingParameters
    $EmailBody += Set-EmailReportBranding -FormattingParameters $FormattingParameters
    $EmailBody += Set-EmailReportDetails -FormattingParameters $FormattingParameters -Dates $Dates -Warnings $Warnings

    # prepare body with HTML
    if ($ReportOptions.AsHTML.Use) {
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportTable $ServersAD -ReportTableText 'Following AD servers were detected in forest'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.Custom.FilesData.Enabled -ReportTable $TableEventLogFiles -ReportTableText 'Following files have been processed for events'
        $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportTable $EventLogTable -ReportTableText 'Following event log sizes were reported'
        foreach ($ReportName in $ReportDefinitions.ReportsAD.EventBased.Keys) {
            $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName -ToLowerCase
            $EmailBody += Export-ReportToHTML -Report $ReportDefinitions.ReportsAD.EventBased.$ReportName.Enabled -ReportTable $Results.$ReportName -ReportTableText "Following $ReportNameTitle happened"

        }
    }

    $Reports = @()

    if ($ReportOptions.AsDynamicHTML.Use) {
        $ReportFileName = Set-ReportFile -FileNamePattern $ReportOptions.AsDynamicHTML.FilePattern -DateFormat $ReportOptions.AsDynamicHTML.DateFormat

        $ReportStarter = New-HTML -Open -TitleText $ReportOptions.AsDynamicHTML.Title `
            -HideLogos:(-not $ReportOptions.AsDynamicHTML.Branding.Logo.Show) `
            -RightLogoString $ReportOptions.AsDynamicHTML.Branding.Logo.RightLogo.ImageLink `
            -UseCssLinks:$ReportOptions.AsDynamicHTML.EmbedCSS `
            -UseStyleLinks:$ReportOptions.AsDynamicHTML.EmbedJS

        $Report = New-GenericList
        $Report.Add($ReportStarter)
        foreach ($ReportName in $ReportDefinitions.ReportsAD.EventBased.Keys) {
            $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName
            if ($ReportDefinitions.ReportsAD.EventBased.$ReportName.Enabled) {
                $Report.Add($(Get-HTMLContent -Open -HeaderText $ReportNameTitle ))
                $Report.Add($(Get-HTMLColumn -Open -ColumnNumber 1 -ColumnCount 1 ))
                if ($null -ne $Results.$ReportName) {
                    $Report.Add($(Get-HTMLContentDataTable -ArrayOfObjects $Results.$ReportName -HideFooter))
                }
                $Report.Add($(Get-HTMLColumn -Close))
            }
            $Report.Add($(Get-HTMLContent -Close))
        }
        $Report.Add((New-HTML -Close))

        [string] $DynamicHTMLPath = Save-HTML -HTML $Report -FilePath "$($ReportOptions.AsDynamicHTML.Path)\$ReportFileName"

        $Reports += $DynamicHTMLPath
    }

    if ($ReportOptions.AsExcel) {
        $Logger.AddInfoRecord('Prepare XLSX files with Events')
        $ReportFilePathXLSX = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension "xlsx"
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Processed Servers" -ReportTable $ServersAD
        Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Event log sizes" -ReportTable $EventLogTable

        foreach ($ReportName in $ReportDefinitions.ReportsAD.EventBased.Keys) {
            $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName
            Export-ReportToXLSX -Report $ReportDefinitions.ReportsAD.EventBased.$ReportName.Enabled -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName $ReportNameTitle -ReportTable $Results.$ReportName
        }
        $Reports += $ReportFilePathXLSX
    }
    if ($ReportOptions.AsCSV) {
        $Logger.AddInfoRecord('Prepare CSV files with Events')
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportServers" -ReportTable $ServersAD
        $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportEventLogSize" -ReportTable $EventLogTable

        foreach ($ReportName in $ReportDefinitions.ReportsAD.EventBased.Keys) {
            $Reports += Export-ReportToCSV -Report $ReportDefinitions.ReportsAD.EventBased.$ReportName.Enabled -ReportOptions $ReportOptions -Extension "csv" -ReportName $ReportName -ReportTable $Results.$ReportName
        }
    }
    $Reports = $Reports |  Where-Object { $_ } | Sort-Object -Unique

    $Logger.AddInfoRecord('Prepare Email replacements and formatting')
    # Do Cleanup of Emails

    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateDays**' -ReplaceWith $time.Elapsed.Days
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateHours**' -ReplaceWith $time.Elapsed.Hours
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateMinutes**' -ReplaceWith $time.Elapsed.Minutes
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateSeconds**' -ReplaceWith $time.Elapsed.Seconds
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateMilliseconds**' -ReplaceWith $time.Elapsed.Milliseconds
    $EmailBody = Set-EmailFormatting -Template $EmailBody -FormattingParameters $FormattingParameters -ConfigurationParameters $ReportOptions -Logger $Logger

    $Time.Stop()

    # Sending email - finalizing package
    if ($ReportOptions.SendMail) {

        foreach ($Report in $Reports) {
            $Logger.AddInfoRecord("Following files will be attached to email $Report")
        }


        $TemporarySubject = $EmailParameters.EmailSubject -replace "<<DateFrom>>", "$($Dates.DateFrom)" -replace "<<DateTo>>", "$($Dates.DateTo)"
        $Logger.AddInfoRecord('Sending email with reports')
        if ($FormattingParameters.CompanyBranding.Inline) {
            $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject -InlineAttachments @{logo = $FormattingParameters.CompanyBranding.Logo} #-Verbose
        } else {
            $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject #-Verbose
        }
        if ($SendMail.Status) {
            $Logger.AddInfoRecord('Email successfully sent')
        } else {
            $Logger.AddInfoRecord("Error sending message: $($SendMail.Error)")
        }
    }

    if ($ReportOptions.AsHTML.Use) {
        $ReportHTMLPath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension 'html'
        $EmailBody | Out-File -Encoding Unicode -FilePath $ReportHTMLPath
        $Logger.AddInfoRecord("Saving report to file: $ReportHTMLPath")
        if ($ReportOptions.AsHTML.OpenAsFile) { Invoke-Item $ReportHTMLPath }
    }
    if ($ReportOptions.AsDynamicHTML.Use -and $ReportOptions.AsDynamicHTML.OpenAsFile) { Invoke-Item $DynamicHTMLPath }

    foreach ($ReportName in $ReportDefinitions.ReportsAD.EventBased.Keys) {
        $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName
        Export-ReportToSql -Report $ReportDefinitions.ReportsAD.EventBased.$ReportName -ReportOptions $ReportOptions -ReportName $ReportNameTitle -ReportTable $Results.$ReportName
    }
    Remove-ReportsFiles -KeepReports $ReportOptions.KeepReports -AsExcel $ReportOptions.AsExcel -AsCSV $ReportOptions.AsCSV -ReportFiles $Reports
}
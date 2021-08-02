function Start-ReportSpecial {
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $Dates,
        [alias('ReportOptions')][System.Collections.IDictionary] $Options,
        [alias('ReportDefinitions')][System.Collections.IDictionary] $Definitions,
        [alias('Servers', 'Computers')][System.Collections.IDictionary] $Target
    )
    $Verbose = ($PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true)
    $Time = Start-TimeLog
    $AttachedReports = @()
    $AttachXLSX = @()
    $AttachHTML = @()
    $AttachDynamicHTML = @()
    $AttachCSV = @()

    [Array] $ExtendedInput = Get-ServersList -Definitions $Definitions -Target $Target
    foreach ($Entry in $ExtendedInput) {
        if ($Entry.Type -eq 'Computer') {
            $Logger.AddInfoRecord("Computer $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')")
        } else {
            $Logger.AddInfoRecord("File $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')")
        }
    }
    # Scan all events and get everything at once
    [Array] $AllEvents = Get-Events -ExtendedInput $ExtendedInput -ErrorAction SilentlyContinue -ErrorVariable AllErrors -Verbose:$Verbose -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo

    $Logger.AddInfoRecord("Found $($AllEvents.Count) events.")
    foreach ($Errors in $AllErrors) {
        $Logger.AddErrorRecord($Errors)
    }

    if ($Options.RemoveDuplicates.Enabled) {
        $Logger.AddInfoRecord("Removing Duplicates from all events. Current list contains $($AllEvents.Count) events")
        $AllEvents = Remove-DuplicateObjects -Object $AllEvents -Property $Options.RemoveDuplicates.Properties
        $Logger.AddInfoRecord("Removed Duplicates - following $($AllEvents.Count) events will be analyzed further")
    }

    $Results = Get-EventsOutput -Definitions $Definitions -AllEvents $AllEvents

    # Prepare email body - tables (real data)
    if ($Options.AsHTML.Enabled) {
        # Prepare email body
        $Logger.AddInfoRecord('Prepare email head and body')
        $HtmlHead = Set-EmailHead -FormattingOptions $Options.AsHTML.Formatting
        $HtmlBody = Set-EmailReportBranding -FormattingParameters $Options.AsHTML.Formatting
        $HtmlBody += Set-EmailReportDetails -FormattingParameters $Options.AsHTML.Formatting -Dates $Dates -Warnings $Warnings

        foreach ($ReportName in $Definitions.Keys) {
            $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName -ToLowerCase
            $HtmlBody += Export-ReportToHTML -Report $Definitions.$ReportName.Enabled -ReportTable $Results.$ReportName -ReportTableText "Following $ReportNameTitle happened"

        }
        # Do Cleanup of Emails
        $HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateDays**' -ReplaceWith $time.Elapsed.Days
        $HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateHours**' -ReplaceWith $time.Elapsed.Hours
        $HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateMinutes**' -ReplaceWith $time.Elapsed.Minutes
        $HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateSeconds**' -ReplaceWith $time.Elapsed.Seconds
        $HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateMilliseconds**' -ReplaceWith $time.Elapsed.Milliseconds
        $HtmlBody = Set-EmailFormatting -Template $HtmlBody -FormattingParameters $Options.AsHTML.Formatting -ConfigurationParameters $Options -Logger $Logger -SkipNewLines

        $HTML = $HtmlHead + $HtmlBody
        $ReportHTMLPath = Set-ReportFile -Path $Options.AsHTML.Path -FileNamePattern $Options.AsHTML.FilePattern -DateFormat $Options.AsHTML.DateFormat
        try {
            $HTML | Out-File -Encoding Unicode -FilePath $ReportHTMLPath -ErrorAction Stop
            $Logger.AddInfoRecord("Saving report to file: $ReportHTMLPath")
            if ($Options.SendMail.Attach.HTML) {
                $AttachHTML += $ReportHTMLPath
                $AttachedReports += $ReportHTMLPath
            }
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            $Logger.AddErrorRecord("Error saving file $ReportHTMLPath.")
            $Logger.AddErrorRecord("Error: $ErrorMessage")
        }
    }


    if ($Options.AsDynamicHTML.Enabled) {
        $DynamicHTMLPath = Set-ReportFile -Path $Options.AsDynamicHTML.Path -FileNamePattern $Options.AsDynamicHTML.FilePattern -DateFormat $Options.AsDynamicHTML.DateFormat

        $null = New-HTML -TitleText $Options.AsDynamicHTML.Title -UseCssLinks:$Options.AsDynamicHTML.EmbedCSS -UseJavaScriptLinks:$Options.AsDynamicHTML.EmbedJS {
            foreach ($ReportName in $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport' }) {
                $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName
                if ($Definitions.$ReportName.Enabled) {
                    New-HTMLSection -HeaderText $ReportNameTitle -CanCollapse {
                        New-HTMLPanel {
                            if ($null -ne $Results.$ReportName) {
                                New-HTMLTable -DataTable $Results.$ReportName -HideFooter
                            }
                        }
                    }
                }
            }
        } -FilePath $DynamicHTMLPath

        try {
            if ($Options.SendMail.Attach.DynamicHTML) {
                $AttachDynamicHTML += $DynamicHTMLPath
                $AttachedReports += $DynamicHTMLPath
            }
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            $Logger.AddErrorRecord("Error saving file $ReportHTMLPath.")
            $Logger.AddErrorRecord("Error: $ErrorMessage")
        }

    }
    if ($Options.AsExcel.Enabled) {
        $Logger.AddInfoRecord('Prepare Microsoft Excel (.XLSX) file with Events')
        $ReportFilePathXLSX = Set-ReportFile -Path $Options.AsExcel.Path -FileNamePattern $Options.AsExcel.FilePattern -DateFormat $Options.AsExcel.DateFormat

        foreach ($ReportName in $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport' }) {
            $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName
            Export-ReportToXLSX -Report $Definitions.$ReportName.Enabled -ReportOptions $Options -ReportFilePath $ReportFilePathXLSX -ReportName $ReportNameTitle -ReportTable $Results.$ReportName
        }
        if ($Options.SendMail.Attach.XLSX) {
            $AttachXLSX += $ReportFilePathXLSX
            $AttachedReports += $ReportFilePathXLSX
        }
    }
    if ($Options.AsCSV.Enabled) {
        $ReportFilePathCSV = @()
        $Logger.AddInfoRecord('Prepare CSV files with Events')

        foreach ($ReportName in $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport' }) {
            $ReportFilePathCSV += Export-ToCSV -Report $Definitions.$ReportName.Enabled -ReportName $ReportName -ReportTable $Results.$ReportName -Path $Options.AsCSV.Path -FilePattern $Options.AsCSV.FilePattern -DateFormat $Options.AsCSV.DateFormat
        }
        if ($Options.SendMail.Attach.CSV) {
            $AttachCSV += $ReportFilePathCSV
            $AttachedReports += $ReportFilePathCSV
        }
    }
    if ($Options.AsHTML.Enabled -and $Options.AsHTML.OpenAsFile) {
        try {
            if ($ReportHTMLPath -ne '' -and (Test-Path -LiteralPath $ReportHTMLPath)) {
                Invoke-Item -LiteralPath $ReportHTMLPath
            }
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            $Logger.AddErrorRecord("Error opening file $ReportHTMLPath.")
        }
    }
    if ($Options.AsDynamicHTML.Enabled -and $Options.AsDynamicHTML.OpenAsFile) {
        try {
            if ($DynamicHTMLPath -ne '' -and (Test-Path -LiteralPath $DynamicHTMLPath)) {
                Invoke-Item -LiteralPath $DynamicHTMLPath
            }
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            $Logger.AddErrorRecord("Error opening file $DynamicHTMLPath.")
        }
    }
    if ($Options.AsExcel.Enabled -and $Options.AsExcel.OpenAsFile) {
        try {
            if ($ReportFilePathXLSX -ne '' -and (Test-Path -LiteralPath $ReportFilePathXLSX)) {
                Invoke-Item -LiteralPath $ReportFilePathXLSX
            }
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            $Logger.AddErrorRecord("Error opening file $ReportFilePathXLSX.")
        }
    }
    if ($Options.AsCSV.Enabled -and $Options.AsCSV.OpenAsFile) {
        foreach ($CSV in $AttachCSV) {
            try {
                if ($CSV -ne '' -and (Test-Path -LiteralPath $CSV)) {
                    Invoke-Item -LiteralPath $CSV
                }
            } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                $Logger.AddErrorRecord("Error opening file $CSV.")
            }
        }
    }


    $AttachedReports = $AttachedReports | Sort-Object -Unique

    # Sending email - finalizing package
    if ($Options.SendMail.Enabled) {
        foreach ($Report in $AttachedReports) {
            $Logger.AddInfoRecord("Following files will be attached to email $Report")
        }
        if ($Options.SendMail.InlineHTML) {
            $EmailBody = $HTML
        } else {
            $EmailBody = ''
        }

        $TemporarySubject = $Options.SendMail.Parameters.Subject -replace "<<DateFrom>>", "$($Dates.DateFrom)" -replace "<<DateTo>>", "$($Dates.DateTo)"
        $Logger.AddInfoRecord('Sending email with reports')
        if ($Options.AsHTML.Formatting.CompanyBranding.Inline) {
            $SendMail = Send-Email -EmailParameters $Options.SendMail.Parameters -Body $EmailBody -Attachment $AttachedReports -Subject $TemporarySubject -InlineAttachments @{logo = $Options.AsHTML.Formatting.CompanyBranding.Logo } -Logger $Logger
        } else {
            $SendMail = Send-Email -EmailParameters $Options.SendMail.Parameters -Body $EmailBody -Attachment $AttachedReports -Subject $TemporarySubject -Logger $Logger
        }
        if ($SendMail.Status) {
            $Logger.AddInfoRecord('Email successfully sent')
        } else {
            $Logger.AddErrorRecord("Error sending message: $($SendMail.Error)")
        }
        Remove-ReportsFiles -KeepReports $Options.SendMail.KeepReports.XLSX -ReportFiles $AttachXLSX
        Remove-ReportsFiles -KeepReports $Options.SendMail.KeepReports.CSV -ReportFiles $AttachCSV
        Remove-ReportsFiles -KeepReports $Options.SendMail.KeepReports.HTML -ReportFiles $AttachHTML
        Remove-ReportsFiles -KeepReports $Options.SendMail.KeepReports.DynamicHTML -ReportFiles $AttachDynamicHTML
    }
    foreach ($ReportName in $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport' }) {
        $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName
        Export-ToSql -Report $Definitions.$ReportName -ReportOptions $Options -ReportName $ReportNameTitle -ReportTable $Results.$ReportName
    }

    $ElapsedTime = Stop-TimeLog -Time $Time
    $Logger.AddInfoRecord("Time to finish $ElapsedTime")
}
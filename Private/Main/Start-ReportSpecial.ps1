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
    $EventIDs = New-GenericList
    $Results = @{}
    $AttachedReports = @()
    $AttachXLSX = @()
    $AttachHTML = @()
    $AttachDynamicHTML = @()
    $AttachCSV = @()

    # Get Servers
    $ServersList = New-ArrayList
    if ($Target.Servers.Enabled) {
        $Logger.AddInfoRecord("Preparing servers list - defined list")
        [Array] $Servers = foreach ($Server in $Target.Servers.Keys | Where-Object { $_ -ne 'Enabled' }) {

            if ($Target.Servers.$Server -is [System.Collections.IDictionary]) {
                #$Target.Servers.$Server
                [ordered] @{
                    ComputerName = $Target.Servers.$Server.ComputerName
                    LogName      = $Target.Servers.$Server.LogName
                }

            } elseif ($Target.Servers.$Server -is [Array] -or $Target.Servers.$Server -is [string]) {
                $Target.Servers.$Server
            }
        }
        $null = $ServersList.AddRange($Servers)
    }
    if ($Target.DomainControllers.Enabled) {
        $Logger.AddInfoRecord("Preparing servers list - domain controllers autodetection")
        [Array] $Servers = (Get-WinADDomainControllers -SkipEmpty).HostName
        $null = $ServersList.AddRange($Servers)
    }
    if ($Target.LocalFiles.Enabled) {
        $Logger.AddInfoRecord("Preparing file list - defined event logs")
        $Files = Get-EventLogFileList -Sections $Target.LocalFiles
    }

    # Get LogNames
    $LogNames = foreach ($Report in  $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport'}) {
        if ($Definitions.$Report.Enabled) {
            foreach ($SubReport in $Definitions.$Report.Keys | Where-Object { $_ -notcontains 'Enabled' }) {
                if ($Definitions.$Report.$SubReport.Enabled) {
                    $Definitions.$Report.$SubReport.LogName

                }
            }
        }
    }

    # Prepare list of servers and files to scan and their relation to LogName and EventIDs and DataTimes
    <#
        Server                                                    LogName         EventID                     Type
        ------                                                    -------         -------                     ----
        AD1                                                       Security        {5136, 5137, 5141, 5136...} Computer
        AD2                                                       Security        {5136, 5137, 5141, 5136...} Computer
        EVO1                                                      ForwardedEvents {5136, 5137, 5141, 5136...} Computer
        AD1.ad.evotec.xyz                                         Security        {5136, 5137, 5141, 5136...} Computer
        AD2.ad.evotec.xyz                                         Security        {5136, 5137, 5141, 5136...} Computer
        C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx Security        {5136, 5137, 5141, 5136...} File
        C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx Security        {5136, 5137, 5141, 5136...} File
        C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx Security        {5136, 5137, 5141, 5136...} File
        C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx Security        {5136, 5137, 5141, 5136...} File
        AD1                                                       System          104                         Computer
        AD2                                                       System          104                         Computer
        EVO1                                                      ForwardedEvents 104                         Computer
        AD1.ad.evotec.xyz                                         System          104                         Computer
        AD2.ad.evotec.xyz                                         System          104                         Computer
        C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx System          104                         File
        C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx System          104                         File
        C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx System          104                         File
        C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx System          104                         File
    #>

    [Array] $ExtendedInput = foreach ($Log in $LogNames | Sort-Object -Unique) {
        $EventIDs = foreach ($Report in  $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport'}) {
            if ($Definitions.$Report.Enabled) {
                foreach ($SubReport in $Definitions.$Report.Keys | Where-Object { $_ -notcontains 'Enabled' }) {
                    if ($Definitions.$Report.$SubReport.Enabled) {
                        if ($Definitions.$Report.$SubReport.LogName -eq $Log) {
                            $Definitions.$Report.$SubReport.Events
                        }
                    }
                }
            }
        }
        #$Logger.AddInfoRecord("Preparing to scan log $Log for Events:$($EventIDs -join ', ')")

        $OutputServers = foreach ($Server in $ServersList) {
            if ($Server -is [System.Collections.IDictionary]) {
                [PSCustomObject]@{
                    Server   = $Server.ComputerName
                    LogName  = $Server.LogName
                    EventID  = $EventIDs | Sort-Object -Unique
                    Type     = 'Computer'
                    DateFrom = $Dates.DateFrom
                    DateTo   = $Dates.DateTo
                }
            } elseif ($Server -is [Array] -or $Server -is [string]) {
                foreach ($S in $Server) {
                    [PSCustomObject]@{
                        Server   = $S
                        LogName  = $Log
                        EventID  = $EventIDs | Sort-Object -Unique
                        Type     = 'Computer'
                        DateFrom = $Dates.DateFrom
                        DateTo   = $Dates.DateTo
                    }
                }
            }
        }
        $OutputFiles = foreach ($File in $FIles) {
            [PSCustomObject]@{
                Server   = $File
                LogName  = $Log
                EventID  = $EventIDs | Sort-Object -Unique
                Type     = 'File'
                DateFrom = $Dates.DateFrom
                DateTo   = $Dates.DateTo
            }
        }
        $OutputServers
        $OutputFiles
    }
    foreach ($Entry in $ExtendedInput) {
        if ($Entry.Type -eq 'Computer') {
            $Logger.AddInfoRecord("Computer $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')")
        } else {
            $Logger.AddInfoRecord("File $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')")
        }
    }
    # Scan all events and get everything at once
    $AllEvents = Get-Events `
        -ExtendedInput $ExtendedInput `
        -ErrorAction SilentlyContinue `
        -ErrorVariable AllErrors `
        -Verbose:$Verbose

    $Logger.AddInfoRecord("Found $($AllEvents.Count) events.")
    foreach ($Errors in $AllErrors) {
        $Logger.AddErrorRecord($Errors)
    }

    if ($Options.RemoveDuplicates.Enabled) {
        $Logger.AddInfoRecord("Removing Duplicates from all events. Current list contains $(Get-ObjectCount -Object $AllEvents) events")
        $AllEvents = Remove-DuplicateObjects -Object $AllEvents -Property $Options.RemoveDuplicates.Properties
        $Logger.AddInfoRecord("Removed Duplicates Following $(Get-ObjectCount -Object $AllEvents) events will be analyzed further")
    }


    # Prepare the results based on chosen criteria
    foreach ($Report in  $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled' }) {
        if ($Definitions.$Report.Enabled) {
            #$ReportNameTitle = Format-AddSpaceToSentence -Text $Report -ToLowerCase
            $Logger.AddInfoRecord("Running $Report")
            $TimeExecution = Start-TimeLog
            foreach ($SubReport in $Definitions.$Report.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport'  }) {
                if ($Definitions.$Report.$SubReport.Enabled) {
                    $Logger.AddInfoRecord("Running $Report with subsection $SubReport")
                    [string] $EventsType = $Definitions.$Report.$SubReport.LogName
                    [Array] $EventsNeeded = $Definitions.$Report.$SubReport.Events
                    [Array] $EventsFound = Find-EventsNeeded -Events $AllEvents -EventIDs $EventsNeeded -EventsType $EventsType
                    [Array] $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $Definitions.$Report.$SubReport
                    $Logger.AddInfoRecord("Ending $Report with subsection $SubReport events found $($EventsFound.Count)")
                    $Results.$Report = $EventsFound
                }
            }
            $ElapsedTimeReport = Stop-TimeLog -Time $TimeExecution -Option OneLiner
            $Logger.AddInfoRecord("Ending $Report - Time to run $ElapsedTimeReport")
        }
    }

    # Prepare email body - tables (real data)
    if ($Options.AsHTML.Enabled) {
        # Prepare email body
        $Logger.AddInfoRecord('Prepare email head and body')
        $HtmlHead = Set-EmailHead -FormattingOptions $Options.AsHTML.Formatting
        $HtmlBody = Set-EmailReportBranding -FormattingParameters $Options.AsHTML.Formatting
        $HtmlBody += Set-EmailReportDetails -FormattingParameters $Options.AsHTML.Formatting -Dates $Dates -Warnings $Warnings

        #$EmailBody += Export-ReportToHTML -Report $Definitions.ReportsAD.Custom.ServersData.Enabled -ReportTable $ServersAD -ReportTableText 'Following AD servers were detected in forest'
        #$EmailBody += Export-ReportToHTML -Report $Definitions.ReportsAD.Custom.FilesData.Enabled -ReportTable $TableEventLogFiles -ReportTableText 'Following files have been processed for events'
        #$EmailBody += Export-ReportToHTML -Report $Definitions.ReportsAD.Custom.EventLogSize.Enabled -ReportTable $EventLogTable -ReportTableText 'Following event log sizes were reported'
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
        #$ReportHTMLPath = Set-ReportFileName -ReportOptions $Options -ReportExtension 'html'
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
        $ReportFileName = Set-ReportFile -Path $Options.AsDynamicHTML.Path -FileNamePattern $Options.AsDynamicHTML.FilePattern -DateFormat $Options.AsDynamicHTML.DateFormat

        $DynamicHTML = New-HTML -TitleText $Options.AsDynamicHTML.Title `
            -HideLogos:(-not $Options.AsDynamicHTML.Branding.Logo.Show) `
            -RightLogoString $Options.AsDynamicHTML.Branding.Logo.RightLogo.ImageLink `
            -UseCssLinks:$Options.AsDynamicHTML.EmbedCSS `
            -UseStyleLinks:$Options.AsDynamicHTML.EmbedJS {

            foreach ($ReportName in $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport' }) {
                $ReportNameTitle = Format-AddSpaceToSentence -Text $ReportName
                if ($Definitions.$ReportName.Enabled) {
                    New-HTMLContent -HeaderText $ReportNameTitle -CanCollapse {
                        New-HTMLColumn -Columns 1 {
                            if ($null -ne $Results.$ReportName) {
                                Get-HTMLContentDataTable -ArrayOfObjects $Results.$ReportName -HideFooter
                            }
                        }
                    }
                }

            }
        }
        if ($null -ne $DynamicHTML) {
            try {
                [string] $DynamicHTMLPath = Save-HTML -HTML $DynamicHTML -FilePath $ReportFileName
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
    }
    if ($Options.AsExcel.Enabled) {
        $Logger.AddInfoRecord('Prepare Microsoft Excel (.XLSX) file with Events')
        $ReportFilePathXLSX = Set-ReportFile -Path $Options.AsExcel.Path -FileNamePattern $Options.AsExcel.FilePattern -DateFormat $Options.AsExcel.DateFormat
        # $ReportFilePathXLSX = Set-ReportFileName -ReportOptions $Options -ReportExtension "xlsx"
        #Export-ReportToXLSX -Report $Definitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $Options -ReportFilePath $ReportFilePathXLSX -ReportName "Processed Servers" -ReportTable $ServersAD
        #Export-ReportToXLSX -Report $Definitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $Options -ReportFilePath $ReportFilePathXLSX -ReportName "Event log sizes" -ReportTable $EventLogTable

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
        #$ReportFilePathCSV += Export-ReportToCSV -Report $Definitions.ReportsAD.Custom.ServersData.Enabled -ReportOptions $Options -Extension "csv" -ReportName "ReportServers" -ReportTable $ServersAD
        #$ReportFilePathCSV += Export-ReportToCSV -Report $Definitions.ReportsAD.Custom.EventLogSize.Enabled -ReportOptions $Options -Extension "csv" -ReportName "ReportEventLogSize" -ReportTable $EventLogTable

        foreach ($ReportName in $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport' }) {
            $ReportFilePathCSV += Export-ToCSV -Report $Definitions.$ReportName.Enabled -ReportName $ReportName -ReportTable $Results.$ReportName -Path $Options.AsCSV.Path -FilePattern $Options.AsCSV.FilePattern -DateFormat $Options.AsCSV.DateFormat
        }
        if ($Options.SendMail.Attach.CSV) {
            $AttachCSV += $ReportFilePathCSV
            $AttachedReports += $ReportFilePathCSV
        }
    }
    if ($Options.AsHTML.Enabled -and $Options.AsHTML.OpenAsFile) {
        if ($ReportHTMLPath -ne '' -and (Test-Path -LiteralPath $ReportHTMLPath)) {
            Invoke-Item -LiteralPath $ReportHTMLPath
        }
    }
    if ($Options.AsDynamicHTML.Enabled -and $Options.AsDynamicHTML.OpenAsFile) {
        if ($DynamicHTMLPath -ne '' -and (Test-Path -LiteralPath $DynamicHTMLPath)) {
            Invoke-Item -LiteralPath $DynamicHTMLPath
        }
    }
    if ($Options.AsExcel.Enabled -and $Options.AsExcel.OpenAsFile) {
        if ($ReportFilePathXLSX -ne '' -and (Test-Path -LiteralPath $ReportFilePathXLSX)) {
            Invoke-Item -LiteralPath $ReportFilePathXLSX
        }
    }
    if ($Options.AsCSV.Enabled -and $Options.AsCSV.OpenAsFile) {
        foreach ($CSV in $AttachCSV) {
            if ($CSV -ne '' -and (Test-Path -LiteralPath $CSV)) {
                Invoke-Item -LiteralPath $CSV
            }
        }
    }

    $AttachedReports = $AttachedReports |  Where-Object { $_ } | Sort-Object -Unique


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
            $SendMail = Send-Email -EmailParameters $Options.SendMail.Parameters -Body $EmailBody -Attachment $AttachedReports -Subject $TemporarySubject -InlineAttachments @{logo = $Options.AsHTML.Formatting.CompanyBranding.Logo} -Logger $Logger
        } else {
            $SendMail = Send-Email -EmailParameters $Options.SendMail.Parameters -Body $EmailBody -Attachment $AttachedReports -Subject $TemporarySubject -Logger $Logger
        }
        if ($SendMail.Status) {
            $Logger.AddInfoRecord('Email successfully sent')
        } else {
            $Logger.AddInfoRecord("Error sending message: $($SendMail.Error)")
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
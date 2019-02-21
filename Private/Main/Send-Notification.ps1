function Send-Notificaton {
    [CmdletBinding()]
    param(
        [PSCustomObject] $Events,
        [Parameter(Mandatory = $true)][alias('ReportOptions')][System.Collections.IDictionary] $Options,
        [string] $Priority = 'Default'
    )
    Begin {}
    Process {
        if ($Events -ne $null) {
            foreach ($Event in $Events) {
                [string] $MessageTitle = 'Active Directory Changes'
                [string] $ActivityTitle = $($Event.Action).Trim()


                # Building message
                $Teams = Get-NotificationParameters -Type 'Microsoft Teams' -Notifications $Options.Notifications.MicrosoftTeams -ActivityTitle $ActivityTitle -Priority $Priority
                $Slack = Get-NotificationParameters -Type 'Slack' -Notifications $Options.Notifications.Slack -ActivityTitle $ActivityTitle -Priority $Priority
                $Discord = Get-NotificationParameters -Type 'Discord' -Notifications $Options.Notifications.Discord -ActivityTitle $ActivityTitle -Priority $Priority

                $FactsSlack = @()
                $FactsTeams = @()
                $FactsDiscord = @()
                foreach ($Property in $event.PSObject.Properties) {
                    if ($Property.Value -ne $null -and $Property.Value -ne '') {
                        if ($Property.Name -eq 'When') {
                            $FactsTeams += New-TeamsFact -Name $Property.Name -Value $Property.Value.DateTime
                            $FactsSlack += @{ title = $Property.Name; value = $Property.Value.DateTime; short = $true }
                            $FactsDiscord += New-DiscordFact -Name $Property.Name -Value $Property.Value.DateTime -Inline $true
                        } else {
                            $FactsTeams += New-TeamsFact -Name $Property.Name -Value $Property.Value
                            $FactsSlack += @{ title = $Property.Name; value = $Property.Value; short = $true }
                            $FactsDiscord += New-DiscordFact -Name $Property.Name -Value $Property.Value -Inline $true
                        }
                    }
                }

                # Slack Notifications
                if ($Options.Notifications.Slack.Enabled) {
                    $SlackChannel = $Options.Notifications.Slack.$Priority.Channel
                    $SlackColor = ConvertFrom-Color -Color $Slack.Color

                    $Data = New-SlackMessageAttachment -Color $SlackColor `
                        -Title "$MessageTitle - $ActivityTitle"  `
                        -Fields $FactsSlack `
                        -Fallback $ActivityTitle |
                        New-SlackMessage -Channel $SlackChannel `
                        -IconEmoji :bomb:  |
                        Send-SlackMessage -Uri $Slack.Uri -Verbose

                    Write-Color @script:WriteParameters -Text "[i] Slack output: ", $Data -Color White, Yellow
                }
                # Microsoft Teams Nofications
                if ($Options.Notifications.MicrosoftTeams.Enabled) {

                    $Section1 = New-TeamsSection `
                        -ActivityTitle $ActivityTitle `
                        -ActivityImageLink $Teams.ActivityImageLink `
                        -ActivityDetails $FactsTeams

                    $Data = Send-TeamsMessage `
                        -URI $Teams.Uri `
                        -MessageTitle $MessageTitle `
                        -Color $Teams.Color `
                        -Sections $Section1 `
                        -Supress $false `
                        -MessageSummary $ActivityTitle
                    # -Verbose
                    Write-Color @script:WriteParameters -Text "[i] Teams output: ", $Data -Color White, Yellow
                }
                # Discord Notifications
                if ($Options.Notifications.Discord.Enabled) {
                    $Thumbnail = New-DiscordImage -Url $Discord.ActivityImageLink

                    $Section1 = New-DiscordSection `
                        -Title $ActivityTitle `
                        -Facts $FactsDiscord `
                        -Thumbnail $Thumbnail `
                        -Color $Discord.Color -Verbose

                    $Data = Send-DiscordMessage `
                        -WebHookUrl $Discord.Uri `
                        -Sections $Section1 `
                        -AvatarName $Discord.AvatarName `
                        -AvatarUrl $Discord.AvatarUrl `
                        -OutputJSON

                    Write-Color @script:WriteParameters -Text "[i] Discord output: ", $Data -Color White, Yellow
                }
                if ($Options.Notifications.MSSQL.Enabled) {
                    $SqlQuery = Send-SqlInsert -Object $Events -SqlSettings $Options.Notifications.MSSQL -Verbose:$Options.Debug.Verbose
                    foreach ($Query in $SqlQuery) {
                        Write-Color @script:WriteParameters -Text '[i] ', 'MS SQL Output: ', $Query -Color White, White, Yellow
                    }
                }
                if ($Options.Notifications.Email.Enabled) {
                    # Prepare email body
                    $Logger.AddInfoRecord('Prepare email head and body')
                    $HtmlHead = Set-EmailHead -FormattingOptions $Options.AsHTML.Formatting
                    $HtmlBody = Set-EmailReportBranding -FormattingParameters $Options.AsHTML.Formatting
                    #$HtmlBody += Set-EmailReportDetails -FormattingParameters $Options.AsHTML.Formatting -Dates $Dates -Warnings $Warnings

                    $HtmlBody += Export-ReportToHTML -Report $true-ReportTable $Events -ReportTableText "Quick notification event"

                    # Do Cleanup of Emails
                    #$HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateDays**' -ReplaceWith $time.Elapsed.Days
                    #$HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateHours**' -ReplaceWith $time.Elapsed.Hours
                    #$HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateMinutes**' -ReplaceWith $time.Elapsed.Minutes
                    #$HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateSeconds**' -ReplaceWith $time.Elapsed.Seconds
                    #$HtmlBody = Set-EmailWordReplacements -Body $HtmlBody -Replace '**TimeToGenerateMilliseconds**' -ReplaceWith $time.Elapsed.Milliseconds
                    $HtmlBody = Set-EmailFormatting -Template $HtmlBody -FormattingParameters $Options.AsHTML.Formatting -ConfigurationParameters $Options -Logger $Logger -SkipNewLines

                    $HTML = $HtmlHead + $HtmlBody
                    #$ReportHTMLPath = Set-ReportFileName -ReportOptions $Options -ReportExtension 'html'
                    $ReportHTMLPath = Set-ReportFile -Path $Env:TEMP -FileNamePattern 'PSWinReporting.html' -DateFormat $null
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

                    $TemporarySubject = $Options.SendMail.Parameters.Subject -replace "<<DateFrom>>", "$($Dates.DateFrom)" -replace "<<DateTo>>", "$($Dates.DateTo)"
                    $Logger.AddInfoRecord('Sending email with reports')
                    if ($Options.Notifications.Email.Formatting.CompanyBranding.Inline) {
                        $SendMail = Send-Email -EmailParameters $Options.SendMail.Parameters -Body $EmailBody -Attachment $AttachedReports -Subject $TemporarySubject -InlineAttachments @{logo = $Options.AsHTML.Formatting.CompanyBranding.Logo} -Logger $Logger
                    } else {
                        $SendMail = Send-Email -EmailParameters $Options.SendMail.Parameters -Body $EmailBody -Attachment $AttachedReports -Subject $TemporarySubject -Logger $Logger
                    }
                    if ($SendMail.Status) {
                        $Logger.AddInfoRecord('Email successfully sent')
                    } else {
                        $Logger.AddInfoRecord("Error sending message: $($SendMail.Error)")
                    }
                    Remove-ReportFiles -KeepReports $false -ReportFiles
                }
            }
        }
    }
    End {}
}
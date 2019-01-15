function Send-Notificaton {
    [CmdletBinding()]
    param(
        [PSCustomObject] $Events,
        [System.Collections.IDictionary] $ReportOptions,
        [string] $Priority = 'Default'
    )
    Begin {
        if ($ReportOptions.Notifications.Slack.Use -eq $false -or
            $ReportOptions.Notifications.MicrosoftTeams.Use -eq $false -or
            $ReportOptions.Notifications.Discord.Use -eq $false -or
            $ReportOptions.Notifications.MSSQL.Use -eq $false) {
            return
        }
    }
    Process {
        if ($Events -ne $null) {
            foreach ($Event in $Events) {
                [string] $MessageTitle = 'Active Directory Changes'
                [string] $ActivityTitle = $($Event.Action).Trim()


                # Building message
                $Teams = Get-NotificationParameters -Type 'Microsoft Teams' -Notifications $ReportOptions.Notifications.MicrosoftTeams -ActivityTitle $ActivityTitle -Priority $Priority
                $Slack = Get-NotificationParameters -Type 'Slack' -Notifications $ReportOptions.Notifications.Slack -ActivityTitle $ActivityTitle -Priority $Priority
                $Discord = Get-NotificationParameters -Type 'Discord' -Notifications $ReportOptions.Notifications.Discord -ActivityTitle $ActivityTitle -Priority $Priority

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
                if ($ReportOptions.Notifications.Slack.Use) {
                    $SlackChannel = $ReportOptions.Notifications.Slack.$Priority.Channel
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
                if ($ReportOptions.Notifications.MicrosoftTeams.Use) {

                    $Section1 = New-TeamsSection `
                        -ActivityTitle $ActivityTitle `
                        -ActivityImageLink $Teams.ActivityImageLink `
                        -ActivityDetails $FactsTeams

                    $Data = Send-TeamsMessage `
                        -URI $Teams.Uri `
                        -MessageTitle $MessageTitle `
                        -Color $Teams.Color `
                        -Sections $Section1 `
                        -Supress $false #`
                    # -Verbose
                    Write-Color @script:WriteParameters -Text "[i] Teams output: ", $Data -Color White, Yellow
                }
                # Discord Notifications
                if ($ReportOptions.Notifications.Discord.Use) {
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
                if ($ReportOptions.Notifications.MSSQL.Use) {
                    $SqlQuery = Send-SqlInsert -Object $Events -SqlSettings $ReportOptions.Notifications.MSSQL -Verbose:$ReportOptions.Debug.Verbose
                    foreach ($Query in $SqlQuery) {
                        Write-Color @script:WriteParameters -Text '[i] ', 'MS SQL Output: ', $Query -Color White, White, Yellow
                    }
                }
            }
        }
    } End {

    }
}
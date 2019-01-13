function Send-Notificaton {
    [CmdletBinding()]
    param(
        [PSCustomObject] $Events,
        [System.Collections.IDictionary] $ReportOptions
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
                [string] $ActivityPriority = 'Default'



                # Building message

                if ($ActivityTitle -like '*added*') {
                    $Color = [RGBColors]::Green
                    $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20120.png'
                } elseif ($ActivityTitle -like '*remove*') {
                    $Color = [RGBColors]::Red
                    $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20130.png'
                } else {
                    $Color = [RGBColors]::Yellow
                    $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20140.png'
                }




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

                ### Notifications

                $SlackURI = $ReportOptions.Notifications.Slack.$ActivityPriority.Uri
                $TeamsURI = $ReportOptions.Notifications.MicrosoftTeams.$ActivityPriority.Uri
                $DiscordURI = $ReportOptions.Notifications.Discord.$ActivityPriority.Uri

                # Slack Notifications
                if ($ReportOptions.Notifications.Slack.Use) {
                    $SlackChannel = $ReportOptions.Notifications.Slack.$ActivityPriority.Channel

                    $Data = New-SlackMessageAttachment -Color 'Yellow' `
                        -Title "$MessageTitle - $ActivityTitle"  `
                        -Fields $FactsSlack `
                        -Fallback 'Your client is bad' |
                        New-SlackMessage -Channel $SlackChannel `
                        -IconEmoji :bomb: |
                        Send-SlackMessage -Uri $SlackURI

                    Write-Color @script:WriteParameters -Text "[i] Slack output: ", $Data -Color White, Yellow
                }
                # Microsoft Teams Nofications
                if ($ReportOptions.Notifications.MicrosoftTeams.Use) {

                    $Section1 = New-TeamsSection `
                        -ActivityTitle $ActivityTitle `
                        -ActivityImageLink $ActivityImageLink `
                        -ActivityDetails $FactsTeams

                    $Data = Send-TeamsMessage `
                        -URI $TeamsURI `
                        -MessageTitle $MessageTitle `
                        -Color $Color `
                        -Sections $Section1 `
                        -Supress $false #`
                    # -Verbose
                    Write-Color @script:WriteParameters -Text "[i] Teams output: ", $Data -Color White, Yellow
                }
                # Discord Notifications
                if ($ReportOptions.Notifications.Discord.Use) {

                    $AvatarName = $ReportOptions.Notifications.Discord.$ActivityPriority.AvatarName
                    $AvatarUrl = $ReportOptions.Notifications.Discord.$ActitityPriority.AvatarImage

                    $Thumbnail = New-DiscordImage -Url $ActivityImageLink

                    $Section1 = New-DiscordSection `
                        -Title $ActivityTitle `
                        -Facts $FactsDiscord `
                        -Thumbnail $Thumbnail `
                        -Color $Color

                    $Data = Send-DiscordMessage `
                        -WebHookUrl $DiscordURI `
                        -Sections $Section1 `
                        -AvatarName $AvatarName `
                        -AvatarUrl $AvatarUrl `
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
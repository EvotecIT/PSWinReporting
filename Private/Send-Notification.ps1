function Send-Notificaton {
    [CmdletBinding()]
    param(
        [PSCustomObject] $Events,
        [hashtable] $ReportOptions
    )

    if ($Events -ne $null) {
        foreach ($Event in $Events) {
            if ($ReportOptions.Notifications.Slack.Use -or $ReportOptions.Notifications.MicrosoftTeams.Use) {
                $MessageTitle = 'Active Directory Changes'
                [string] $ActivityTitle = $($Event.Action).Trim()
                if ($ActivityTitle -like '*added*') {
                    $Color = [System.Drawing.Color]::Green
                    $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20120.png'
                } elseif ($ActivityTitle -like '*remove*') {
                    $Color = [System.Drawing.Color]::Red
                    $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20130.png'
                } else {
                    $Color = [System.Drawing.Color]::Yellow
                    $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20140.png'
                }

                $FactsSlack = @()
                $FactsTeams = @()
                foreach ($Property in $event.PSObject.Properties) {
                    if ($Property.Value -ne $null -and $Property.Value -ne '') {
                        if ($Property.Name -eq 'When') {
                            $FactsTeams += New-TeamsFact -Name $Property.Name -Value $Property.Value.DateTime
                            $FactsSlack += @{ title = $Property.Name; value = $Property.Value.DateTime; short = $true }
                        } else {
                            $FactsTeams += New-TeamsFact -Name $Property.Name -Value $Property.Value
                            $FactsSlack += @{ title = $Property.Name; value = $Property.Value; short = $true }
                        }
                    }
                }
            }

            if ($ReportOptions.Notifications.Slack.Use) {
                $Data = New-SlackMessageAttachment -Color $Color `
                    -Title "$MessageTitle - $ActivityTitle"  `
                    -Fields $FactsSlack `
                    -Fallback 'Your client is bad' |
                    New-SlackMessage -Channel $ReportOptions.Notifications.Slack.Channel `
                    -IconEmoji :bomb: |
                    Send-SlackMessage -Uri $ReportOptions.Notifications.Slack.URI
                $Logger.AddRecord("Slack output: $Data")
            }
            if ($ReportOptions.Notifications.MicrosoftTeams.Use) {

                $Section1 = New-TeamsSection `
                    -ActivityTitle $ActivityTitle `
                    -ActivityImageLink $ActivityImageLink `
                    -ActivityDetails $FactsTeams

                $Data = Send-TeamsMessage `
                    -URI $ReportOptions.Notifications.MicrosoftTeams.TeamsID `
                    -MessageTitle $MessageTitle `
                    -Color $Color `
                    -Sections $Section1 `
                    -Supress $false
                $Logger.AddRecord("Teams output: $Data")
            }
            if ($ReportOptions.Notifications.MSSQL.Use) {
                $SqlQuery = Send-SqlInsert -Object $Events -SqlSettings $ReportOptions.Notifications.MSSQL -Verbose:$ReportOptions.Debug.Verbose
                foreach ($Query in $SqlQuery) {
                    $Logger.AddRecord("MS SQL output: $Query")
                }
            }
        }
    }
}
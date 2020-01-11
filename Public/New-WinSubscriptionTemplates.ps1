function New-WinSubscriptionTemplates {
    [CmdletBinding()]
    param (
        [string[]] $Servers,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [string[]] $ExcludeDomainControllers,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [alias('DomainControllers')][string[]] $IncludeDomainControllers,
        [switch] $SkipRODC,
        [ValidateScript( { $_ -in (& $SourcesAutoCompleter) })][string[]] $Reports,
        [switch] $AddTemplates,
        [alias('ReportDefinitions')][System.Collections.IDictionary] $Definitions,
        [System.Collections.IDictionary] $Target,
        [System.Collections.IDictionary] $LoggerParameters
    )
    Begin {
        if (-not $LoggerParameters) {
            $LoggerParameters = $Script:LoggerParameters
        }
        $Logger = Get-Logger @LoggerParameters

        if (-not $Reports) {
            # Adds all reports if not provided
            $Reports = (Get-EventsDefinitions).Keys
        }
        if (-not $Definitions) {
            # Bring defaults if definitions isn't provided
            $Definitions = $Script:ReportDefinitions
        }
        foreach ($Report in $Reports) {
            $Definitions[$Report].Enabled = $true
        }

        if (-not $Target) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExcludeDomainControllers $ExcludeDomainControllers -IncludeDomainControllers $IncludeDomainControllers -SkipRODC:$SkipRODC

            $Target = [ordered]@{
                Servers           = [ordered] @{
                    Enabled     = $true
                    ServerDCs   = $ForestInformation.ForestDomainControllers.HostName
                    ServerOther = $Servers
                }
            }
        }
    }
    Process {
        [Array] $ExtendedInput = Get-ServersList -Definitions $Definitions -Target $Target
        foreach ($Entry in $ExtendedInput) {
            if ($Entry.Type -eq 'Computer') {
                $Logger.AddInfoRecord("Computer $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')")
            } else {
                $Logger.AddInfoRecord("File $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')")
            }
        }
        $xmlTemplate = "$($($(Get-Module -ListAvailable PSWinReportingV2)[0]).ModuleBase)\Templates\Template-Collector.xml"
        #$XmlTemplate = "$((Get-Item $PSScriptRoot).Parent.FullName)\Templates\Template-Collector.xml"
        if (Test-Path -LiteralPath $xmlTemplate) {
            $Logger.AddInfoRecord("Found Template $xmlTemplate")
            $SubscriptionCount = 0

            $InputServers = ($ExtendedInput | Group-Object -Property LogName)

            $ListTemplates = foreach ($InputData in $InputServers) {
                $Servers = $InputData.Group.Server
                $EventID = $InputData.Group.EventID | Select-Object -Unique
                $LogName = $InputData.Name

                $SplitArrayID = Split-Array -inArray $EventID -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
                $Array = foreach ($ID in $SplitArrayID) {
                    #New-EventQuery -Events $ID -Type $LogName
                    Get-EventsFilter -ID $ID -LogName $LogName
                }
                foreach ($Events in $Array) {
                    $SubscriptionCount++
                    $SubscriptionTemplate = "$ENV:TEMP\PSWinReportingSubscription$SubscriptionCount.xml"
                    Copy-Item -Path $xmlTemplate -Destination $SubscriptionTemplate
                    $Logger.AddInfoRecord("Copied template $SubscriptionTemplate")
                    Add-ServersToXML -FilePath $SubscriptionTemplate -Servers $Servers

                    Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'SubscriptionId' -Value "PSWinReporting Subscription Events - $SubscriptionCount"
                    Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'ContentFormat' -Value 'Events'
                    Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'ConfigurationMode' -Value 'Custom'
                    #$Events
                    Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'Query' -Value $Events
                    $SubscriptionTemplate
                }
            }
        } else {
            $Logger.AddInfoRecord("Template not found $xmlTemplate")
        }
        if ($AddTemplates) {
            Set-SubscriptionTemplates -ListTemplates $ListTemplates -DeleteOwn -LoggerParameters $LoggerParameters
        }
    }
    End {
        # This prevents duplication of reports on second script run
        # It resets reports to being disabled by default
        foreach ($Report in $Script:ReportDefinitions.Keys) {
            $Script:ReportDefinitions[$Report].Enabled = $false
        }
    }
}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Reports = (Get-EventsDefinitions).Keys
    $Reports | Sort-Object
}

Register-ArgumentCompleter -CommandName New-WinSubscriptionTemplates -ParameterName Reports -ScriptBlock $SourcesAutoCompleter
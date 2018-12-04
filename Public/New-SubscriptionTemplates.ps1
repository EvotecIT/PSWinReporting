function New-SubscriptionTemplates {
	[CmdletBinding()]
	param (
		[System.Collections.IDictionary] $ReportDefinitions,
        [System.Collections.IDictionary] $LoggerParameters
    )

    $Params = @{
        LogPath = Join-Path $LoggerParameters.LogsDir "$([datetime]::Now.ToString('yyyy.MM.dd_hh.mm'))_ADReporting.log"
        ShowTime = $LoggerParameters.ShowTime
        TimeFormat = $LoggerParameters.TimeFormat
    }
    $Logger = Get-Logger @Params

	$Events = Get-EventsData -ReportDefinitions $ReportDefinitions -LogName 'Security'
    $Systems = Get-EventsData -ReportDefinitions $ReportDefinitions -LogName 'System'

	#Write-Color 'Found Security Events ', ([string] $Events) -Color White, Yellow
    #Write-Color 'Found System Events ', ([string] $Systems) -Color White, Yellow

    $Logger.AddInfoRecord("Found Security Events $($Events -join ', ')")
    $Logger.AddInfoRecord("Found System Events $($Systems -join ', ')")

	$ServersAD = Get-DC
	$Servers = Find-ServersAD -ReportDefinitions $ReportDefinitions -DC $ServersAD
    #Write-Color 'Found Servers ', ([string] $Servers) -Color White, Yellow
    $Logger.AddInfoRecord("Found Servers $($Servers -join ', ')")
	# $xmlTemplate = "$($($(Get-Module -ListAvailable PSWinReporting)[0]).ModuleBase)\Templates\Template-Collector.xml"
	$XmlTemplate = "$((get-item $PSScriptRoot).Parent.FullName)\Templates\Template-Collector.xml"
	if (Test-Path $xmlTemplate) {
        $Logger.AddInfoRecord("Found Template $xmlTemplate")
		#Write-Color 'Found Template ', $xmlTemplate -Color White, Yellow
		$ListTemplates = New-ArrayList
		if (Test-Path $xmlTemplate) {
			$Array = New-ArrayList
			$SplitArrayID = Split-Array -inArray $Events -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
			foreach ($ID in $SplitArrayID) {
				$Query = New-EventQuery -Events $ID -Type 'Security' #-Verbose
				Add-ToArray -List $Array -Element $Query
			}
			$SplitArrayID = Split-Array -inArray $Systems -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
			foreach ($ID in $SplitArrayID) {
				$Query = New-EventQuery -Events $ID -Type 'System' #-Verbose
				Add-ToArray -List $Array -Element $Query
			}
			$i = 0
			foreach ($Events in $Array) {
				$i++
				$SubscriptionTemplate = "$ENV:TEMP\PSWinReportingSubscription$i.xml"
                Copy-Item -Path $xmlTemplate $SubscriptionTemplate
                $Logger.AddInfoRecord("Copied template $SubscriptionTemplate")
				#Write-Color 'Copied template ', $SubscriptionTemplate -Color White, Yellow
				Add-ServersToXML -FilePath $SubscriptionTemplate -Servers $Servers

				Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'SubscriptionId' -Value "PSWinReporting Subscription Events - $i"
				Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'ContentFormat' -Value 'Events'
				Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'ConfigurationMode' -Value 'Custom'
				#$Events
				Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'Query' -Value $Events
				Add-ToArray -List $ListTemplates -Element $SubscriptionTemplate
			}

		}
	} else {
        $Logger.AddInfoRecord("Template not found $xmlTemplate")
		#Write-Color 'Template not found ', $xmlTemplate -Color White, Yellow
	}
	return $ListTemplates
}
function New-SubscriptionTemplates {
    [CmdletBinding()]
    param (
        $ReportDefinitions
    )
    $Events = Get-EventsData -ReportDefinitions $ReportDefinitions -LogName 'Security'
    $Systems = Get-EventsData -ReportDefinitions $ReportDefinitions -LogName 'System'
    Write-Color 'Found Security Events ', ([string] $Events) -Color White, Yellow
    Write-Color 'Found System Events ', ([string] $Systems) -Color White, Yellow
    $ServersAD = Get-DC
    $Servers = Find-ServersAD -ReportDefinitions $ReportDefinitions -DC $ServersAD
    Write-Color 'Found Servers ', ([string] $Servers) -Color White, Yellow
    # $xmlTemplate = "$($($(Get-Module -ListAvailable PSWinReporting)[0]).ModuleBase)\Templates\Template-Collector.xml"
    $XmlTemplate = "$((get-item $PSScriptRoot).Parent.FullName)\Templates\Template-Collector.xml"
    if (Test-Path $xmlTemplate) {
        Write-Color 'Found Template ', $xmlTemplate -Color White, Yellow
        $ListTemplates = New-ArrayList
        if (Test-Path $xmlTemplate) {
            $Array = New-ArrayList
            $SplitArrayID = Split-Array -inArray $Events -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
            foreach ($ID in $SplitArrayID) {
                $Query = New-EventQuery -Events $ID -Type 'Security' -Verbose
                Add-ToArray -List $Array -Element $Query
            }
            $SplitArrayID = Split-Array -inArray $Systems -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
            foreach ($ID in $SplitArrayID) {
                $Query = New-EventQuery -Events $ID -Type 'System' -Verbose
                Add-ToArray -List $Array -Element $Query
            }
            $i = 0
            foreach ($Events in $Array) {
                $i++
                $SubscriptionTemplate = "$ENV:TEMP\PSWinReportingSubscription$i.xml"
                Copy-Item -Path $xmlTemplate $SubscriptionTemplate
                Write-Color 'Copied template ', $SubscriptionTemplate -Color White, Yellow
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
        Write-Color 'Template not found ', $xmlTemplate -Color White, Yellow
    }
    return $ListTemplates
}
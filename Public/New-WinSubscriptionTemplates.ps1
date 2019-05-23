function New-WinSubscriptionTemplates {
    [CmdletBinding()]
    param (
        [alias('ReportDefinitions')][System.Collections.IDictionary] $Definitions,
        [alias('Servers', 'Computers')][System.Collections.IDictionary] $Target,
        [System.Collections.IDictionary] $LoggerParameters,
        [switch] $AddTemplates
    )
    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters

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
        $ListTemplates = foreach ($InputData in $ExtendedInput) {
            $SplitArrayID = Split-Array -inArray $InputData.EventID -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
            $Array = foreach ($ID in $SplitArrayID) {
                New-EventQuery -Events $ID -Type $InputData.LogName
            }
            foreach ($Events in $Array) {
                $SubscriptionCount++
                $SubscriptionTemplate = "$ENV:TEMP\PSWinReportingSubscription$SubscriptionCount.xml"
                Copy-Item -Path $xmlTemplate -Destination $SubscriptionTemplate
                $Logger.AddInfoRecord("Copied template $SubscriptionTemplate")
                Add-ServersToXML -FilePath $SubscriptionTemplate -Servers $InputData.Server

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
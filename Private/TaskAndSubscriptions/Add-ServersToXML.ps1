function Add-ServersToXML {
    [CmdletBinding()]
    param (
        [string] $FilePath,
        [string[]] $Servers
    )
    [xml]$xmlDocument = Get-Content -Path $FilePath -Encoding UTF8
    foreach ($Server in $Servers) {
        $node = $xmlDocument.CreateElement('EventSource', $xmlDocument.Subscription.NamespaceURI)
        $node.SetAttribute('Enabled', 'true')

        $nodeServer = $xmlDocument.CreateElement('Address', $xmlDocument.Subscription.NamespaceURI)
        $nodeServer.set_InnerXML($Server)

        [void] $xmlDocument.Subscription.Eventsources.AppendChild($node) #> $null
        [void] $xmlDocument.Subscription.Eventsources.EventSource.AppendChild($nodeServer) #> $null
    }
    Save-XML -FilePath $FilePath -xml $xmlDocument
}

function Add-ServersToXML {
    param (
        [string] $FilePath,
        [string[]] $Servers
    )
    #$doc = New-Object System.Xml.XmlDocument
    #$doc.Load($filePath)
    [xml]$xmlDocument = Get-Content -Path $FilePath -Encoding UTF8

    foreach ($Server in $Servers) {
        $node = $xmlDocument.CreateElement('EventSource', $xmlDocument.Subscription.NamespaceURI)
        $node.SetAttribute('Enabled', 'true')

        $nodeServer = $xmlDocument.CreateElement('Address', $xmlDocument.Subscription.NamespaceURI)
        $nodeServer.set_InnerXML($Server)

        $xmlDocument.Subscription.Eventsources.AppendChild($node) > $null
        $xmlDocument.Subscription.Eventsources.EventSource.AppendChild($nodeServer) > $null
    }

    Save-XML -FilePath $FilePath -xml $xmlDocument
}

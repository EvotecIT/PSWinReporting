function Start-MyProgram {
    [CmdletBinding()]
    param (
        [string] $Program,
        [string[]]$cmdArgList
    )
    return & $Program $cmdArgList
}
function Find-MyProgramData {
    [CmdletBinding()]
    param (
        $Data,
        $FindText
    )
    foreach ($Sub in $Data) {
        if ($Sub -like $FindText) {
            $Split = $Sub.Split(' ')
            return $Split[1]
        }
    }
    return ''
}
function Set-ServersPermissions {
    [CmdletBinding()]
    param (
        $ProgramWevtutil,
        $Servers,
        [string]$LogName = 'security'
    )


    foreach ($DC in $Servers) {
        $cmdArgListGet = @(
            "gl"
            $LogName
            "/r:$DC"
        )
        $cmdArgListSet = @(
            "sl",
            $LogName
            "/r:$DC"
            "/ca:O:BAG:SYD:(A; ; 0xf0005; ; ; SY)(A; ; 0x5; ; ; BA)(A; ; 0x1; ; ; S-1-5-32-573)(A; ; 0x1; ; ; S-1-5-20)"
        )

        Start-MyProgram -Program $Script:ProgramWevtutil -cmdArgList $cmdArgListSet
        Start-MyProgram -Program $Script:ProgramWevtutil -cmdArgList $cmdArgListGet
    }
}
function Get-ServersPermissions {
    param (
        $ProgramWevtutil,
        $Servers,
        [string]$LogName = 'security'
    )


    foreach ($DC in $Servers) {
        $cmdArgListGet = @(
            "gl"
            $LogName
            "/r:$DC"
        )
        Start-MyProgram -Program $Script:ProgramWevtutil -cmdArgList $cmdArgListGet
    }
}
function Set-MissingDescription {
    param()
    $AllSubscriptions = Start-MyProgram -Program $ProgramWecutil -cmdArgList 'es'

    foreach ($Subscription in $AllSubscriptions) {
        $SubData = Start-MyProgram -Program $ProgramWecutil -cmdArgList 'gs', $Subscription
        Find-MyProgramData -Data $SubData -FindText 'ContentFormat*'

        $Change = Start-MyProgram -Program $ProgramWecutil -cmdArgList 'ss', $Subscription, '/cf:Events'
    }
}

#Set-DomainControllersPermissions -ProgramWevtutil $ProgramWevtutil


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

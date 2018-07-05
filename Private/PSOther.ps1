$ProgramWecutil = "wecutil.exe"
$ProgramWevtutil = 'wevtutil.exe'

function Get-EventsData {
    param (
        $ReportDefinitions,
        $LogName
    )
    Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch $LogName
}
function New-EventQuery {
    param (
        [string[]]$Events,
        [string] $Type
    )

    $values = New-ArrayList
    Add-ToArray -List $Values -Element '<![CDATA['
    Add-ToArray -List $Values -Element "<Select Path ="
    Add-ToArray -List $Values -Element "`"$Type`""
    Add-ToArray -List $Values -Element ">*"
    Add-ToArray -List $Values -Element '[System[('
    foreach ($E in $Events) {
        Add-ToArray -List $Values -Element "EventID=$E"
        Add-ToArray -List $Values -Element "or"
    }
    Remove-FromArray -List $values -LastElement
    Add-ToArray -List $Values -Element ')]]</Select>]]>'

    return ([string] $Values).Replace(' ', '').Replace('or', ' or ')
}
function Start-MyProgram {
    param (
        [string] $Program,
        [string[]]$cmdArgList
    )
    return & $Program $cmdArgList
}
function Find-MyProgramData {
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
    param (
        $ProgramWevtutil,
        $Servers
    )


    foreach ($DC in $Servers) {
        $cmdArgListGet = @(
            "gl"
            "security"
            "/r:$DC"
        )
        $cmdArgListSet = @(
            "sl",
            "security"
            "/r:$DC"
            "/ca:O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20)"
        )

        Start-MyProgram -Program $ProgramWevtutil -cmdArgList $cmdArgListSet
        Start-MyProgram -Program $ProgramWevtutil -cmdArgList $cmdArgListGet
    }
}
function Fix-MissingDescription {
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
        $FilePath,
        $Servers
    )
    $doc = New-Object System.Xml.XmlDocument
    $doc.Load($filePath)

    foreach ($Server in $Servers) {
        $node = $doc.CreateElement('EventSource', $doc.Subscription.NamespaceURI)
        $node.SetAttribute('Enabled', 'true')

        $nodeServer = $doc.CreateElement('Address', $doc.Subscription.NamespaceURI)
        $nodeServer.set_InnerXML($Server)

        $doc.Subscription.Eventsources.AppendChild($node)
        $doc.Subscription.Eventsources.EventSource.AppendChild($nodeServer)
    }

    $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
    $sw = New-Object System.IO.StreamWriter($filePath, $false, $utf8WithoutBom)

    $doc.Save( $sw )
    $sw.Close()

    $doc.Save($FilePath)
}

function Set-XML {
    param (
        [string] $FilePath,
        [string] $Node,
        [string] $Value
    )

    $doc = New-Object System.Xml.XmlDocument
    $doc.Load($filePath)
    $doc.Subscription.$node = $value
    $doc.Save($FilePath)
}
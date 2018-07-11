$Script:ProgramWecutil = "wecutil.exe"
$Script:ProgramWevtutil = 'wevtutil.exe'

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
    <#
        <![CDATA[
        <QueryList>
        <Query Id="0" Path="Security">
        <Select Path="Security">*[System[(EventID=122 or EventID=212 or EventID=323)]]</Select>
        </Query>
        </QueryList>
                ]]>
    #>
    $values = New-ArrayList
    #  Add-ToArray -List $Values -Element '<![CDATA[ <QueryList><Query Id="0" Path="Security">'
    Add-ToArray -List $Values -Element '<QueryList><Query Id="0" Path="Security">'
    Add-ToArray -List $Values -Element "<Select Path =", "`"$Type`"", ">*[System[("
    foreach ($E in $Events) {
        Add-ToArray -List $Values -Element "EventID=$E"
        Add-ToArray -List $Values -Element "or"
    }
    Remove-FromArray -List $values -LastElement
    #Add-ToArray -List $Values -Element ')]]</Select></Query></QueryList>]]>'
    Add-ToArray -List $Values -Element ')]]</Select></Query></QueryList>'

    return ([string] $Values) #.Replace(' ', '').Replace('or', ' or ').Replace('SelectPath', 'Select Path')
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

function Set-XML {
    param (
        [string] $FilePath,
        [string[]]$Paths,
        [string] $Node,
        [string] $Value
    )
    [xml]$xmlDocument = Get-Content -Path $FilePath -Encoding UTF8
    $XmlElement = $xmlDocument
    foreach ($Path in $Paths) {
        $XmlElement = $XmlElement.$Path
    }
    $XmlElement.$Node = $Value
    $xmlDocument.Save($FilePath)
    # Save-XML -FilePath $FilePath -xml $xmlDocument
}

function Save-XML {
    param (
        [string] $FilePath,
        [System.Xml.XmlNode] $xml
    )
    $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
    $writer = New-Object System.IO.StreamWriter($FilePath, $false, $utf8WithoutBom)
    $xml.Save( $writer )
    $writer.Close()
}
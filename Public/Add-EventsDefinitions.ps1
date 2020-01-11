function Add-EventsDefinitions {
    [CmdLetBinding()]
    param(
        [parameter(Mandatory = $true)][System.Collections.IDictionary] $Definitions,
        [parameter(Mandatory = $true)][string] $Name,
        [switch] $Force
    )
    # This checks if new definition can be merged.
    $AllDefinitions = Get-EventsDefinitions -Definitions $Definitions
    if ($null -ne $AllDefinitions) {
        [string] $ConfigurationPath = "$Env:ALLUSERSPROFILE\Evotec\PSWinReporting\Definitions"
        $null = New-Item -Type Directory -Path $ConfigurationPath -Force
        if (Test-Path -LiteralPath $ConfigurationPath) {
            $XMLPath = "$ConfigurationPath\$Name.xml"
            if ((Test-Path -LiteralPath $XMLPath) -and (-not $Force)) {
                Write-Warning -Message "Definition with name $Name already exists. Please choose another name or use -Force switch."
                return
            }
            $Definitions | Export-CliXML -LiteralPath $XMLPath -Depth 5
        }
    }
}
function Get-EventsDefinitions {
    [CmdLetBinding()]
    param(
        [System.Collections.IDictionary] $Definitions
    )
    [string] $ConfigurationPath = "$Env:ALLUSERSPROFILE\Evotec\PSWinReporting\Definitions"
    try {
        $Files = Get-ChildItem -LiteralPath $ConfigurationPath -Filter '*.xml' -ErrorAction Stop
    } catch {
        $Files = $null
    }

    $AllDefinitions = $Script:ReportDefinitions
    if ($null -ne $Files) {
        try {
            foreach ($File in $Files) {
                $AllDefinitions += Import-Clixml -LiteralPath $File.FullName
            }
            if ($Definitions) {
                $AllDefinitions += $Definitions
            }
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            if ($ErrorMessage -like '*Item has already been added. Key in dictionary*') {
                Write-Warning "Get-EventsDefinitions - Duplicate key in definition. Please make sure names in Hashtables are unique."
            } else {
                Write-Warning "Get-EventsDefinitions - Error: $ErrorMessage"
            }
            $AllDefinitions = $null
        }
    }
    return $AllDefinitions
}
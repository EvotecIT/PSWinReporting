function Test-Key () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Object] $ConfigurationTable,
        [Parameter(Mandatory = $true)]
        [string] $ConfigurationSection,
        [Parameter(Mandatory = $true)]
        [string] $ConfigurationKey,
        [string] $ValueType,
        [switch] $DisplayProgress
    )
    Write-Verbose "Test-Key ConfigurationKey: $ConfigurationKey, ConfigurationSection: $ConfigurationSection, ValueType: $ValueType, DisplayProgress: $DisplayProgress"
    if ($ConfigurationTable -is [System.Collections.IDictionary]) {
        if (-not $ConfigurationTable.Contains($ConfigurationKey)) {
            if ($DisplayProgress) {
                $Logger.AddErrorRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection doesn't exists.")
            }
            return $false
        }
    }
    #Write-Verbose "Test-Key - Continuing 1"
    if (-not $PSBoundParameters.ContainsKey('ValueType')) {
        if ($DisplayProgress) {
            $Logger.AddSuccessRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection exists")
        }
        return $true
    }
    #Write-Verbose "Test-Key - Continuing 2"
    if ($null -ne $ConfigurationTable.$ConfigurationKey) {
        if (-not ($ConfigurationTable.$ConfigurationKey.GetType().Name -eq $ValueType)) {
            if ($DisplayProgress) {
                $Logger.AddErrorRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection exists but the type of key is incorrect")
            }
            return $false
        }
    } else {
        if ($DisplayProgress) {
            $Logger.AddErrorRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection doesn't exists.")
        }
        return $false
    }
    #Write-Verbose "Test-Key - Continuing 3"
    if ($DisplayProgress) {
        $Logger.AddSuccessRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection exists and correct")
    }
    return $true

}
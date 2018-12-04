function Test-Key () {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary] $ConfigurationTable,
        [Parameter(Mandatory = $true)]
        [string] $ConfigurationSection,
        [Parameter(Mandatory = $true)]
        [string] $ConfigurationKey,
        [string] $ValueType,
        [switch] $DisplayProgress
    )
    if (-not $ConfigurationTable.Contains($ConfigurationKey)) {
        if ($DisplayProgress) {
            $Logger.AddErrorRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection doesn't exist")
        }
        return $false
    }

    if (-not $PSBoundParameters.ContainsKey('ValueType')) {
        if ($DisplayProgress) {
            $Logger.AddSuccessRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection exists")
        }
        return $true
    }

    if (-not ($ConfigurationTable.$ConfigurationKey.GetType().Name -eq $ValueType)) {
        if ($DisplayProgress) {
            $Logger.AddErrorRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection exists but the type of key is incorrect")
        }
        return $false
    }

    if ($DisplayProgress) {
        $Logger.AddSuccessRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection exists and correct")
    }
    return $true

}
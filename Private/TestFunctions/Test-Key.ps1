function Test-Key () {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary] $ConfigurationTable,
        [Parameter(Mandatory = $true)]
        [string] $ConfigurationSection,
        [Parameter(Mandatory = $true)]
        [string] $ConfigurationKey,
        [switch] $DisplayProgress
    )
    if ($ConfigurationTable.Contains($ConfigurationKey)) {
        if ($DisplayProgress) {
            $Logger.AddSuccessRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection exists")
        }
        return $true
    } else {
        if ($DisplayProgress) {
            $Logger.AddErrorRecord("Parameter $ConfigurationKey in configuration of $ConfigurationSection doesn't exist")
        }
        return $false
    }
}
function Test-Key ($ConfigurationTable, $ConfigurationSection = "", $ConfigurationKey, $DisplayProgress = $false) {

    if ($ConfigurationKey -eq $null) { return $false }
    if ($ConfigurationTable -eq $null) { return $false }

    if ($ConfigurationTable.ContainsKey($ConfigurationKey)) {
        if ($DisplayProgress) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " exists." -Color White, White, Green, White
        }
        return $true
    } else {
        if ($DisplayProgress) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " doesn't exist." -Color White, White, Red, White
        }
        return $false
    }
}
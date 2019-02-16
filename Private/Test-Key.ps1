function Test-Key ($ConfigurationTable, $ConfigurationSection = "", $ConfigurationKey, $DisplayProgress = $false) {

    if ($ConfigurationTable -eq $null) { return $false }
    try {
        $value = $ConfigurationTable.ContainsKey($ConfigurationKey)
    } catch {
        $value = $false
    }

    if ($value -eq $true) {
        if ($DisplayProgress -eq $true) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " exists." -Color White, White, Green, White
        }
        return $true
    } else {
        if ($DisplayProgress -eq $true) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " doesn't exist." -Color White, White, Red, White
        }
        return $false
    }
}
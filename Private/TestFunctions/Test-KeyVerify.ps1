function Test-KeyVerify() {
    param(
        [System.Collections.IDictionary] $Object,
        [string] $Key
    )
    if ($Object.Contains($Key)) {
        if ($Object.$Key -eq $true) {
            return $true
        }
    }
    return $false
}
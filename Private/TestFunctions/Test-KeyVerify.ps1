function Test-KeyVerify() {
    param(
        $Object,
        $Key
    )
    if ($Object.Contains($Key)) {
        if ($Object.$Key -eq $true) {
            return $true
        }
    }
    return $false
}
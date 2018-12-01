function Test-KeyVerifyBoth() {
    param(
        [System.Collections.IDictionary] $Object,
        [string] $SubObject,
        [string] $Key
    )
    if ($Object -is [bool]) {
        return $Object
    } else {
        if ($Object.Contains($SubObject)) {
            if ($Object.$SubObject -is [bool]) {
                return $Object.$SubObject
            } else {
                if (($Object.$SubObject).Contains($Key)) {
                    return $Object.$SubObject.$Key
                }
            }
        }
    }
    return $false
}
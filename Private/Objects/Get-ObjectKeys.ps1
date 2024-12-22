function Get-ObjectKeys {
    <#
    .SYNOPSIS
    Retrieves the keys of an object excluding a specified key.

    .DESCRIPTION
    This function retrieves the keys of an object while excluding a specified key. It returns an array of keys from the object.

    .PARAMETER Object
    The object from which keys need to be retrieved.

    .PARAMETER Ignore
    The key to be excluded from the result.

    .EXAMPLE
    $object = @{ 'key1' = 'value1'; 'key2' = 'value2'; 'key3' = 'value3' }
    Get-ObjectKeys -Object $object -Ignore 'key2'
    # Returns 'key1', 'key3'

    #>
    param(
        [object] $Object,
        [string] $Ignore
    )
    $Data = $Object.Keys | Where-Object { $_ -notcontains $Ignore }
    return $Data
}
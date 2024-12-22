function Get-HashMaxValue {
    <#
    .SYNOPSIS
    Gets the maximum value from a hashtable.

    .DESCRIPTION
    This function retrieves the maximum value from a given hashtable. It can also return the minimum value if the -Lowest switch is used.

    .PARAMETER hashTable
    The hashtable from which to find the maximum value.

    .PARAMETER Lowest
    If specified, the function will return the minimum value instead of the maximum.

    .EXAMPLE
    $myHashTable = @{ 'A' = 10; 'B' = 20; 'C' = 5 }
    Get-HashMaxValue -hashTable $myHashTable
    # Output: 20

    .EXAMPLE
    $myHashTable = @{ 'A' = 10; 'B' = 20; 'C' = 5 }
    Get-HashMaxValue -hashTable $myHashTable -Lowest
    # Output: 5
    #>
    [CmdletBinding()]
    param (
        [Object] $hashTable,
        [switch] $Lowest
    )
    if ($Lowest) {
        return ($hashTable.GetEnumerator() | Sort-Object value -Descending | Select-Object -Last 1).Value
    } else {
        return ($hashTable.GetEnumerator() | Sort-Object value -Descending | Select-Object -First 1).Value
    }
}
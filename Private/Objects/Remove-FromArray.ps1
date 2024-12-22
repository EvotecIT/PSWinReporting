function Remove-FromArray {
    <#
    .SYNOPSIS
    Removes an element from an ArrayList.

    .DESCRIPTION
    This function removes a specified element from an ArrayList. It can remove either a specific element or the last element in the list.

    .PARAMETER List
    The ArrayList from which the element will be removed.

    .PARAMETER Element
    The element to be removed from the ArrayList.

    .PARAMETER LastElement
    If this switch is used, the last element in the ArrayList will be removed.

    .EXAMPLE
    $myList = New-Object System.Collections.ArrayList
    $myList.Add("Apple")
    $myList.Add("Banana")
    Remove-FromArray -List $myList -Element "Banana"
    # This will remove the element "Banana" from the ArrayList.

    .EXAMPLE
    $myList = New-Object System.Collections.ArrayList
    $myList.Add("Apple")
    $myList.Add("Banana")
    Remove-FromArray -List $myList -LastElement
    # This will remove the last element in the ArrayList.

    #>
    [CmdletBinding()]
    param(
        [System.Collections.ArrayList] $List,
        [Object] $Element,
        [switch] $LastElement
    )
    if ($LastElement) {
        $LastID = $List.Count - 1
        $List.RemoveAt($LastID) > $null
    } else {
        $List.Remove($Element) > $null
    }
}
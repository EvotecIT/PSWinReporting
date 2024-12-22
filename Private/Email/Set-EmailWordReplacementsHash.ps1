function Set-EmailWordReplacementsHash {
    <#
    .SYNOPSIS
    Replaces words in an email body based on a given hash table of substitutions.

    .DESCRIPTION
    This function replaces words in the email body with specified substitutions using a hash table.

    .PARAMETER Body
    The email body where the word replacements will be applied.

    .PARAMETER Substitute
    A hash table containing the words to be replaced as keys and their corresponding substitutions as values.

    .EXAMPLE
    $body = "Hello, my name is John."
    $substitutions = @{
        "John" = "Jane"
    }
    Set-EmailWordReplacementsHash -Body $body -Substitute $substitutions
    # This will replace "John" with "Jane" in the email body.

    #>
    [CmdletBinding()]
    param (
        $Body,
        $Substitute
    )
    foreach ($Key in $Substitute.Keys) {
        Write-Verbose "Set-EmailWordReplacementsHash - Key: $Key Value: $($Substitute.$Key)"
        $Body = Set-EmailWordReplacements -Body $Body -Replace $Key -ReplaceWith $Substitute.$Key
    }
    return $Body
}
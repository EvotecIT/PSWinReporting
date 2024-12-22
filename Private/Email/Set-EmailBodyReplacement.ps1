function Set-EmailBodyReplacement {
    <#
    .SYNOPSIS
    Replaces specified text in the email body based on the provided replacement table and type.

    .DESCRIPTION
    This function replaces text in the email body with specified formatting based on the replacement table and type provided.

    .PARAMETER Body
    The original email body text.

    .PARAMETER ReplacementTable
    A hashtable containing the text to be replaced as keys and the replacement values as values.

    .PARAMETER Type
    The type of replacement to be performed. Valid values are 'Colors' and 'Bold'.

    .EXAMPLE
    Set-EmailBodyReplacement -Body "This is a test email." -ReplacementTable @{ 'test' = 'green' } -Type Colors
    This example replaces the text 'test' in the email body with green color.

    .EXAMPLE
    Set-EmailBodyReplacement -Body "This is a test email." -ReplacementTable @{ 'test' = $true } -Type Bold
    This example makes the text 'test' bold in the email body.

    #>
    [CmdletBinding()]
    param(
        [string] $Body,
        [hashtable] $ReplacementTable,
        [ValidateSet('Colors', 'Bold')][string] $Type
    )
    switch ($Type) {
        'Colors' {
            foreach ($Field in $ReplacementTable.Keys) {
                $Value = $ReplacementTable.$Field
                $Body = $Body -replace $Field, "<font color=`"$Value`">$Field</font>"
            }
        }
        'Bold' {
            foreach ($Field in $ReplacementTable.Keys) {
                $Value = $ReplacementTable.$Field
                if ($Value -eq $true) {
                    $Body = $Body -replace $Field, "<b>$Field</b>"
                }
            }
        }
    }
    return $Body
}

<#
$ReplacementTable = @{
    ' Added' = 'green'
}

$ReplacementTable = @{
    ' Added' = $true
}
#>
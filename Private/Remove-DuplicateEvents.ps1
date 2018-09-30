function Remove-DuplicateEvents {
    [CmdletBinding()]
    param(
        $Events
    )
    return $Events | Sort-Object -Property 'Record ID' -Unique
}
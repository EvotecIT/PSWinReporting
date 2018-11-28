Function Convert-FromGPO ([string] $OperationType) {
    $Known = @{
        '%%14674' = 'Value Added'
        '%%14675' = 'Value Deleted'
        '%%14676' = 'Unknown'
    }
    foreach ($id in $OperationType) {
        if ($name = $Known[$id]) { return $name }
    }
    return $OperationType
}
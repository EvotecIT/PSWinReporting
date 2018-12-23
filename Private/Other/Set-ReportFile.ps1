function Set-ReportFile {
    param(
        [string] $FileNamePattern,
        [string] $DateFormat,
        [string] $Extension
    )
    $FileNamePattern = $FileNamePattern.Replace('<currentdate>', $(get-date -f $DateFormat))
    $FileNamePattern = $FileNamePattern.Replace('<extension>', $Extension)
    return $FileNamePattern
}
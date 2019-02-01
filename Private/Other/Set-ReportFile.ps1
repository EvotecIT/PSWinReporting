function Set-ReportFile {
    param(
        [string] $Path,
        [alias('FilePattern')][string] $FileNamePattern,
        [string] $DateFormat,
        [string] $Extension,
        [string] $ReportName
    )
    $FileNamePattern = $FileNamePattern.Replace('<currentdate>', $(get-date -f $DateFormat))
    $FileNamePattern = $FileNamePattern.Replace('<extension>', $Extension)
    $FileNamePattern = $FileNamePattern.Replace('<reportname>', $ReportName)
    return "$Path\$FileNamePattern"
}
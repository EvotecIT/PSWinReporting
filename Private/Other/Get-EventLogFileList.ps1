function Get-EventLogFileList {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Sections
    )
    $EventFiles = @(
        if ($Sections.Contains("Directories")) {
            foreach ($Folder in $Sections.Directories.Keys) {
                $Files = Get-FilesInFolder -Folder $Sections.Directories.$Folder -Extension '*.evtx'
                foreach ($File in $Files) {
                    $File
                }
            }
        }
        if ($Sections.Contains("Files")) {
            foreach ($FileName in $Sections.Files.Keys) {
                $File = $($Sections.Files.$FileName)
                if ($File -and (Test-Path -LiteralPath $File)) {
                    $File
                } else {
                    if (-not $Quiet) { $Logger.AddErrorRecord("File $File doesn't exists. Skipping for scan.") }
                }
            }
        }
    )
    return $EventFiles | Sort-Object -Unique
}
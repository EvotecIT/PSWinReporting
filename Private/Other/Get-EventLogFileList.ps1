function Get-EventLogFileList {
    [CmdletBinding()]
    param(
        $Sections
    )
    $EventFiles = New-ArrayList
    if ($Sections.ContainsKey("Directories")) {
        foreach ($Folder in $Sections.Directories.Keys) {
            $Files = Get-FilesInFolder -Folder $Sections.Directories.$Folder -Extension '*.evtx'
            foreach ($File in $Files) {
                Add-ToArrayAdvanced -List $EventFiles -Element $File -RequireUnique
            }
        }
    }
    if ($Sections.ContainsKey("Files")) {
        foreach ($FileName in $Sections.Files.Keys) {
            $File = $($Sections.Files.$FileName)
            Add-ToArrayAdvanced -List $EventFiles -Element $File -RequireUnique
        }
    }
    return $EventFiles
}
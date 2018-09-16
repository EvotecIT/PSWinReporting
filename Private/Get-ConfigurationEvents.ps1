function Get-CongfigurationEvents {
    [CmdletBinding()]
    param(
        $Sections
    )
    $EventFiles = New-ArrayList
    if ($Sections.Directories.Use) {
        foreach ($Folder in $Sections.Directories.Keys) {
            if ($Folder -eq 'Use') { continue }
            if (Test-Path $Sections.Directories.$Folder) {
                $Files = Get-FilesInFolder -Folder $Sections.Directories.$Folder -Extension '*.evtx'
                foreach ($File in $Files) {
                    #Write-Verbose "Get-ConfigurationEvents - Folder: $Folder File: $File"
                    Add-ToArrayAdvanced -List $EventFiles -Element $File -RequireUnique
                }
            }
        }
    }
    if ($Sections.Files.Use) {
        foreach ($FileName in $Sections.Files.Keys) {
            if ($FileName -eq 'Use') { continue }
            $File = $($Sections.Files.$FileName)
            if (Test-Path $File) {
                #Write-Verbose "Get-ConfigurationEvents - File: $File"
                Add-ToArrayAdvanced -List $EventFiles -Element $File -RequireUnique
            }
        }
    }
    return $EventFiles
}
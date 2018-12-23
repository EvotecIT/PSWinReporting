function Test-Modules () {
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $ReportOptions
    )
    $Logger.AddInfoRecord('Testing for prerequisite availability')
    $ImportPSEventViewer = Get-ModulesAvailability -Name "PSEventViewer"
    if ($ImportPSEventViewer -eq $true) {
        $Logger.AddSuccessRecord('PSEventViewer module imported')
    } else {
        $Logger.AddErrorRecord('PSEventViewer module not found')
    }

    $ImportPSADReporting = Get-ModulesAvailability -Name "PSWinReporting"
    if ($ImportPSADReporting) {
        $Logger.AddSuccessRecord('PSWinReporting module imported')
    } else {
        $Logger.AddErrorRecord('PSWinReporting module not found')
    }

    $ImportExcel = Get-ModulesAvailability -Name "PSWriteExcel"
    if ($ImportExcel) {
        $Logger.AddSuccessRecord('PSWriteExcel module imported')
    } else {
        $Logger.AddInfoRecord('PSWriteExcel module not found')
        if ($ReportOptions.AsExcel) {
            $Logger.AddErrorRecord('PSWriteExcel module is not installed. Disable AsExcel under ReportOptions option before rerunning this script')
            $Logger.AddInfoRecord('Alternatively run Install-Module -Name PSWriteExcel before re-running this script. It''s quite useful module!')
            $Logger.AddInfoRecord('If Install-Module is not there as well you need to download PackageManagement PowerShell Modules')
            $Logger.AddInfoRecord('It can be found at https://www.microsoft.com/en-us/download/details.aspx?id=51451. After download, install and re-run Install-Module again.')
        }
    }
    $ImportActiveDirectory = Get-ModulesAvailability -Name "ActiveDirectory"
    if ($ImportActiveDirectory) {
        $Logger.AddSuccessRecord('ActiveDirectory module imported')
    } else {
        $Logger.AddErrorRecord('ActiveDirectory module not found')
        $Logger.AddInfoRecord('Please make sure it''s available on the machine before running this script')
    }

    return ($ImportPSEventViewer -and $ImportPSADReporting -and $ImportActiveDirectory -and (($ReportOptions.AsExcel -and $ImportExcel) -or (-not $ReportOptions.AsExcel)))
}
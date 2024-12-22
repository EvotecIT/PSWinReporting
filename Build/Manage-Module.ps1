Clear-Host

Invoke-ModuleBuild -ModuleName 'PSWinReporting' {
    # Usual defaults as per standard module
    $Manifest = [ordered] @{
        # Version number of this module.
        ModuleVersion = '1.8.1.X'
        # ID used to uniquely identify this module
        GUID          = '4b446d15-93e7-4eec-a6ee-d741f2ae2f3b'
        # Author of this module
        Author        = 'Przemyslaw Klys'
        # Company or vendor of this module
        CompanyName   = 'Evotec'
        # Copyright statement for this module
        Copyright     = "(c) 2011 - $((Get-Date).Year) Przemyslaw Klys @ Evotec. All rights reserved."
        # Description of the functionality provided by this module
        Description   = 'This PowerShell Module, which started as an event library (Get-EventsLibrary.ps1), has now grown up and became full fledged PowerShell Module. This module has multiple functionalities but one of the signature features of this module is ability to parse Security (mostly) logs on Domain Controllers.'
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags          = @('Windows', 'PSWinReporting', 'ActiveDirectory', 'Events', 'Reporting')
        IconUri       = 'https://evotec.xyz/wp-content/uploads/2018/10/PSWinReporting.png'
        ProjectUri    = 'https://github.com/EvotecIT/PSWinReporting'
    }
    New-ConfigurationManifest @Manifest #-Prerelease "Alpha02"

    #New-ConfigurationModule -Type RequiredModule -Name 'PSSharedGoods' -Guid Auto -Version Latest
    New-ConfigurationModule -Type RequiredModule -Name 'PSEventViewer' -Guid Auto -Version 1.0.22
    New-ConfigurationModule -Type RequiredModule -Name 'PSWriteExcel' -Guid Auto -Version 0.1.15
    New-ConfigurationModule -Type RequiredModule -Name 'PSWriteColor' -Guid Auto -Version Latest
    New-ConfigurationModule -Type ExternalModule -Name 'ActiveDirectory'
    New-ConfigurationModule -Type ApprovedModule -Name 'PSSharedGoods', 'PSWriteColor', 'Connectimo', 'PSUnifi', 'PSWebToolbox', 'PSMyPassword'

    New-ConfigurationModuleSkip -IgnoreModuleName @(
        # this are builtin into PowerShell, so not critical
        'Microsoft.PowerShell.Management'
        'Microsoft.PowerShell.Security'
        'Microsoft.PowerShell.Utility'
        'ScheduledTasks'
        # this is optional, and checked for existance in the source codes directly
        'PSTeams'
        'PSSlack'
        'dbatools'
    ) -IgnoreFunctionName @(
        # those functions are internal within private function
        'Select-Unique', 'Compare-TwoArrays', 'IsNumeric', 'IsOfType', 'Format-HTML', 'Optimize-HTML'
        # Special nofunctions
        'eventChannel'
        'eventID'
        'eventRecordID'
        'eventSeverity'
        # slack
        'New-SlackMessage'
        'New-SlackMessageAttachment'
        'Send-SlackMessage'
        # dbatools
        'Invoke-DbaQuery'
    )

    $ConfigurationFormat = [ordered] @{
        RemoveComments                              = $true
        RemoveEmptyLines                            = $true

        PlaceOpenBraceEnable                        = $true
        PlaceOpenBraceOnSameLine                    = $true
        PlaceOpenBraceNewLineAfter                  = $true
        PlaceOpenBraceIgnoreOneLineBlock            = $false

        PlaceCloseBraceEnable                       = $true
        PlaceCloseBraceNewLineAfter                 = $false
        PlaceCloseBraceIgnoreOneLineBlock           = $true
        PlaceCloseBraceNoEmptyLineBefore            = $false

        UseConsistentIndentationEnable              = $true
        UseConsistentIndentationKind                = 'space'
        UseConsistentIndentationPipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
        UseConsistentIndentationIndentationSize     = 4

        UseConsistentWhitespaceEnable               = $true
        UseConsistentWhitespaceCheckInnerBrace      = $true
        UseConsistentWhitespaceCheckOpenBrace       = $true
        UseConsistentWhitespaceCheckOpenParen       = $true
        UseConsistentWhitespaceCheckOperator        = $true
        UseConsistentWhitespaceCheckPipe            = $true
        UseConsistentWhitespaceCheckSeparator       = $true

        AlignAssignmentStatementEnable              = $true
        AlignAssignmentStatementCheckHashtable      = $true

        UseCorrectCasingEnable                      = $true
    }
    # format PSD1 and PSM1 files when merging into a single file
    # enable formatting is not required as Configuration is provided
    New-ConfigurationFormat -ApplyTo 'OnMergePSM1', 'OnMergePSD1' -Sort None @ConfigurationFormat
    # format PSD1 and PSM1 files within the module
    # enable formatting is required to make sure that formatting is applied (with default settings)
    New-ConfigurationFormat -ApplyTo 'DefaultPSD1', 'DefaultPSM1' -EnableFormatting -Sort None
    # when creating PSD1 use special style without comments and with only required parameters
    New-ConfigurationFormat -ApplyTo 'DefaultPSD1', 'OnMergePSD1' -PSD1Style 'Minimal'
    # configuration for documentation, at the same time it enables documentation processing
    New-ConfigurationDocumentation -Enable:$false -StartClean -UpdateWhenNew -PathReadme 'Docs\Readme.md' -Path 'Docs'

    New-ConfigurationImportModule -ImportSelf

    New-ConfigurationBuild -Enable:$true -SignModule -MergeModuleOnBuild -MergeFunctionsFromApprovedModules -CertificateThumbprint '483292C9E317AA13B07BB7A96AE9D1A5ED9E7703'

    #New-ConfigurationTest -TestsPath "$PSScriptRoot\..\Tests" -Enable

    New-ConfigurationArtefact -Type Unpacked -Enable -Path "$PSScriptRoot\..\Artefacts\Unpacked" -AddRequiredModules
    New-ConfigurationArtefact -Type Packed -Enable -Path "$PSScriptRoot\..\Artefacts\Packed" -ArtefactName '<ModuleName>.v<ModuleVersion>.zip'

    # options for publishing to github/psgallery
    #New-ConfigurationPublish -Type PowerShellGallery -FilePath 'C:\Support\Important\PowerShellGalleryAPI.txt' -Enabled:$true
    #New-ConfigurationPublish -Type GitHub -FilePath 'C:\Support\Important\GitHubAPI.txt' -UserName 'EvotecIT' -Enabled:$true
} -ExitCode
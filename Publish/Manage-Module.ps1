Clear-Host
Import-Module "C:\Support\GitHub\PSPublishModule\PSPublishModule.psm1" -Force

$Configuration = @{
    Information = @{
        ModuleName        = 'PSWinReportingV2'

        DirectoryProjects = 'C:\Support\GitHub'
        DirectoryModules  = "$Env:USERPROFILE\Documents\WindowsPowerShell\Modules"
        FunctionsToExport = 'Public'
        AliasesToExport   = 'Public'

        Manifest          = @{
            # Version number of this module.
            ModuleVersion   = '2.0.16'
            # ID used to uniquely identify this module
            GUID            = 'ea2bd8d2-cca1-4dc3-9e1c-ff80b06e8fbe'
            # Author of this module
            Author          = 'Przemyslaw Klys'
            # Company or vendor of this module
            CompanyName     = 'Evotec'
            # Copyright statement for this module
            Copyright       = "(c) 2011 - $((Get-Date).Year) Przemyslaw Klys @ Evotec. All rights reserved."
            # Description of the functionality provided by this module
            Description     = "PSWinReportingV2 is fast and efficient Event Viewing, Event Reporting and Event Collecting tool. It's version 2 of known PSWinReporting PowerShell module and can work next to it."
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags            = @('PSWinReporting', 'ActiveDirectory', 'Events', 'Reporting', 'Windows', 'EventLog')

            IconUri         = 'https://evotec.xyz/wp-content/uploads/2018/10/PSWinReporting.png'

            ProjectUri      = 'https://github.com/EvotecIT/PSWinReporting'
            #ReleaseNotes = ''
            RequiredModules = @(
                @{ ModuleName = 'PSEventViewer'; ModuleVersion = "1.0.12"; Guid = '5df72a79-cdf6-4add-b38d-bcacf26fb7bc' }
                @{ ModuleName = 'PSSharedGoods'; ModuleVersion = "0.0.115"; Guid = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe' }
                @{ ModuleName = 'PSWriteExcel'; ModuleVersion = "0.1.4"; Guid = '82232c6a-27f1-435d-a496-929f7221334b' }
                @{ ModuleName = 'PSWriteHTML'; ModuleVersion = '0.0.71'; Guid = 'a7bdf640-f5cb-4acf-9de0-365b322d245c' }
            )
        }
    }
    Options     = @{
        Merge             = @{
            Sort           = 'None'
            FormatCodePSM1 = @{
                Enabled           = $true
                RemoveComments    = $true
                FormatterSettings = @{
                    IncludeRules = @(
                        'PSPlaceOpenBrace',
                        'PSPlaceCloseBrace',
                        'PSUseConsistentWhitespace',
                        'PSUseConsistentIndentation',
                        'PSAlignAssignmentStatement',
                        'PSUseCorrectCasing'
                    )

                    Rules        = @{
                        PSPlaceOpenBrace           = @{
                            Enable             = $true
                            OnSameLine         = $true
                            NewLineAfter       = $true
                            IgnoreOneLineBlock = $true
                        }

                        PSPlaceCloseBrace          = @{
                            Enable             = $true
                            NewLineAfter       = $false
                            IgnoreOneLineBlock = $true
                            NoEmptyLineBefore  = $false
                        }

                        PSUseConsistentIndentation = @{
                            Enable              = $true
                            Kind                = 'space'
                            PipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
                            IndentationSize     = 4
                        }

                        PSUseConsistentWhitespace  = @{
                            Enable          = $true
                            CheckInnerBrace = $true
                            CheckOpenBrace  = $true
                            CheckOpenParen  = $true
                            CheckOperator   = $true
                            CheckPipe       = $true
                            CheckSeparator  = $true
                        }

                        PSAlignAssignmentStatement = @{
                            Enable         = $true
                            CheckHashtable = $true
                        }

                        PSUseCorrectCasing         = @{
                            Enable = $true
                        }
                    }
                }
            }
            FormatCodePSD1 = @{
                Enabled        = $true
                RemoveComments = $false
            }
            Integrate      = @{
                ApprovedModules = @('PSSharedGoods', 'PSWriteColor', 'Connectimo', 'PSUnifi', 'PSWebToolbox', 'PSMyPassword')
            }
        }
        Standard          = @{
            FormatCodePSM1 = @{

            }
            FormatCodePSD1 = @{
                Enabled = $true
                #RemoveComments = $true
            }
        }
        ImportModules     = @{
            Self            = $true
            RequiredModules = $false
            Verbose         = $false
        }
        PowerShellGallery = @{
            ApiKey   = 'C:\Support\Important\PowerShellGalleryAPI.txt'
            FromFile = $true
        }
        GitHub            = @{
            ApiKey   = 'C:\Support\Important\GithubAPI.txt'
            FromFile = $true
            UserName = 'EvotecIT'
            #RepositoryName = 'PSWriteHTML'
        }
        Documentation     = @{
            Path       = 'Docs'
            PathReadme = 'Docs\Readme.md'
        }
    }
    Steps       = @{
        BuildModule        = @{
            Enable       = $true
            Merge        = $true
            MergeMissing = $false
            Releases     = $true
        }
        BuildDocumentation = $false
        PublishModule      = @{
            Enabled      = $false
            Prerelease   = ''
            RequireForce = $false
            GitHub       = $false
        }
    }
}
New-PrepareModule -Configuration $Configuration -Verbose
@{
    AliasesToExport   = @()
    Author            = 'Przemyslaw Klys'
    CmdletsToExport   = @()
    CompanyName       = 'Evotec'
    Copyright         = '(c) 2011 - 2021 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description       = 'This PowerShell Module, which started as an event library (Get-EventsLibrary.ps1), has now grown up and became full fledged PowerShell Module. This module has multiple functionalities but one of the signature features of this module is ability to parse Security (mostly) logs on Domain Controllers.'
    FunctionsToExport = @('Add-TaskScheduledForwarder', 'New-SubscriptionTemplates', 'Remove-TaskScheduledForwarder', 'Set-SubscriptionTemplates', 'Start-ADReporting', 'Start-Notifications', 'Start-RescanEvents', 'Start-SubscriptionService')
    GUID              = '4b446d15-93e7-4eec-a6ee-d741f2ae2f3b'
    ModuleVersion     = '1.8.1.6'
    PrivateData       = @{
        PSData = @{
            Tags                       = @('Windows', 'PSWinReporting', 'ActiveDirectory', 'Events', 'Reporting')
            ProjectUri                 = 'https://github.com/EvotecIT/PSWinReporting'
            IconUri                    = 'https://evotec.xyz/wp-content/uploads/2018/10/PSWinReporting.png'
            ExternalModuleDependencies = @('ActiveDirectory')
        }
    }
    RequiredModules   = @(@{
            ModuleVersion = '1.0.17'
            ModuleName    = 'PSEventViewer'
            Guid          = '5df72a79-cdf6-4add-b38d-bcacf26fb7bc'
        }, @{
            ModuleVersion = '0.0.211'
            ModuleName    = 'PSSharedGoods'
            Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
        }, @{
            ModuleVersion = '0.1.12'
            ModuleName    = 'PSWriteExcel'
            Guid          = '82232c6a-27f1-435d-a496-929f7221334b'
        }, 'ActiveDirectory')
    RootModule        = 'PSWinReporting.psm1'
}
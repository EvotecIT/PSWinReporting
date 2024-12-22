﻿@{
    AliasesToExport      = @()
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop', 'Core')
    Copyright            = '(c) 2011 - 2024 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'This PowerShell Module, which started as an event library (Get-EventsLibrary.ps1), has now grown up and became full fledged PowerShell Module. This module has multiple functionalities but one of the signature features of this module is ability to parse Security (mostly) logs on Domain Controllers.'
    FunctionsToExport    = @('Add-TaskScheduledForwarder', 'New-SubscriptionTemplates', 'Remove-TaskScheduledForwarder', 'Set-SubscriptionTemplates', 'Start-ADReporting', 'Start-Notifications', 'Start-RescanEvents', 'Start-SubscriptionService')
    GUID                 = '4b446d15-93e7-4eec-a6ee-d741f2ae2f3b'
    ModuleVersion        = '1.8.1.7'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            ExternalModuleDependencies = @('ActiveDirectory')
            IconUri                    = 'https://evotec.xyz/wp-content/uploads/2018/10/PSWinReporting.png'
            ProjectUri                 = 'https://github.com/EvotecIT/PSWinReporting'
            Tags                       = @('Windows', 'PSWinReporting', 'ActiveDirectory', 'Events', 'Reporting')
        }
    }
    RequiredModules      = @(@{
            Guid          = '5df72a79-cdf6-4add-b38d-bcacf26fb7bc'
            ModuleName    = 'PSEventViewer'
            ModuleVersion = '1.0.22'
        }, @{
            Guid          = '82232c6a-27f1-435d-a496-929f7221334b'
            ModuleName    = 'PSWriteExcel'
            ModuleVersion = '0.1.15'
        }, @{
            Guid          = '0b0ba5c5-ec85-4c2b-a718-874e55a8bc3f'
            ModuleName    = 'PSWriteColor'
            ModuleVersion = '1.0.1'
        }, 'ActiveDirectory')
    RootModule           = 'PSWinReporting.psm1'
}
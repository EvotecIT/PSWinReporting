@{
    AliasesToExport   = @()
    Author            = 'Przemyslaw Klys'
    CmdletsToExport   = @()
    CompanyName       = 'Evotec'
    Copyright         = '(c) 2011 - 2021 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description       = 'PSWinReportingV2 is fast and efficient Event Viewing, Event Reporting and Event Collecting tool. It''s version 2 of known PSWinReporting PowerShell module and can work next to it.'
    FunctionsToExport = @('Add-EventsDefinitions', 'Add-WinTaskScheduledForwarder', 'Find-Events', 'New-WinSubscriptionTemplates', 'Remove-WinTaskScheduledForwarder', 'Start-WinNotifications', 'Start-WinReporting', 'Start-WinSubscriptionService')
    GUID              = 'ea2bd8d2-cca1-4dc3-9e1c-ff80b06e8fbe'
    ModuleVersion     = '2.0.21'
    PrivateData       = @{
        PSData = @{
            Tags       = @('PSWinReporting', 'ActiveDirectory', 'Events', 'Reporting', 'Windows', 'EventLog')
            ProjectUri = 'https://github.com/EvotecIT/PSWinReporting'
            IconUri    = 'https://evotec.xyz/wp-content/uploads/2018/10/PSWinReporting.png'
        }
    }
    RequiredModules   = @(@{
            ModuleVersion = '1.0.17'
            ModuleName    = 'PSEventViewer'
            Guid          = '5df72a79-cdf6-4add-b38d-bcacf26fb7bc'
        }, @{
            ModuleVersion = '0.0.198'
            ModuleName    = 'PSSharedGoods'
            Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
        }, @{
            ModuleVersion = '0.1.13'
            ModuleName    = 'PSWriteExcel'
            Guid          = '82232c6a-27f1-435d-a496-929f7221334b'
        }, @{
            ModuleVersion = '0.0.145'
            ModuleName    = 'PSWriteHTML'
            Guid          = 'a7bdf640-f5cb-4acf-9de0-365b322d245c'
        })
    RootModule        = 'PSWinReportingV2.psm1'
}
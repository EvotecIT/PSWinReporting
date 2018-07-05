# required modules
Install-Module -Name PSEventViewer
Install-Module -Name PSWinReporting
Install-Module -Name PSWriteColor
Install-Module -Name ImportExcel
# Updates to already installed modules
Update-Module # Updates all modules.. cool (in case you already done the above at least onece)

# Just in case you want to chcck what you have
Get-InstalledModule # Shows installed modules
Get-Module -ListAvailable # Shows all modules (including multiple versions)
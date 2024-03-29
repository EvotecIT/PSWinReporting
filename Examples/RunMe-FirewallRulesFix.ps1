$DC = Get-ADDomainController -Filter *
Invoke-Command -ComputerName $DC.HostName {
    Set-NetFirewallRule -DisplayGroup 'Remote Event Log Management' -Enabled True -PassThru | Select-Object DisplayName, Enabled
}
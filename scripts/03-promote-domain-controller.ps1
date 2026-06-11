# Promotes AKL-DC01 to Domain Controller for servicedesk.lab.
# Creates a new forest, installs DNS, and sets the DSRM password.
# The server RESTARTS automatically when this completes.
# After reboot, log in as SERVICEDESK\Administrator.

$domainName  = "servicedesk.lab"   # Change in ALL scripts if you use a different domain
$netbiosName = "SERVICEDESK"

# DSRM (Directory Services Restore Mode) password — used only for
# recovery scenarios. It is NOT the domain Administrator password.
# Store it somewhere safe; you'll rarely need it but losing it hurts.
$dsrmPassword = Read-Host "Enter DSRM Password" -AsSecureString

Write-Host "=== Promoting to Domain Controller ==="
Import-Module ADDSDeployment

# ForestMode/DomainMode "WinThreshold" = Server 2016+ functional level.
# CreateDnsDelegation is $false because there is no parent DNS zone
# above servicedesk.lab to delegate from (it's a private lab domain).
Install-ADDSForest `
    -DomainName $domainName `
    -DomainNetbiosName $netbiosName `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns:$true `
    -CreateDnsDelegation:$false `
    -SafeModeAdministratorPassword $dsrmPassword `
    -Force:$true

Write-Host "`n=== Server will restart ==="
Write-Host "After reboot, log in as SERVICEDESK\Administrator"
Write-Host "Then run scripts/04-verify-domain.ps1"
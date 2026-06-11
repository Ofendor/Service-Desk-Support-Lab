# Promotes server to Domain Controller for servicedesk.lab
# It also installs DNS role if not already installed, and configures DSRM password.
# After running this script, the server will restart. Log in with SERVICEDESK\Administrator.
# Don't forget to save your password and take screenshots for your lab!

$domainName = "servicedesk.lab" # Change this to your desired domain name if needed. Just make sure to update it in all scripts for consistency.
$netbiosName = "SERVICEDESK" #
$dsrmPassword = Read-Host "Enter DSRM Password" -AsSecureString # DSRM password is used for Directory Services Restore Mode, important for recovery scenarios. Make sure to remember it!

Write-Host "=== Promoting to Domain Controller ==="
Import-Module ADDSDeployment # Import the ADDSDeployment module to access the Install-ADDSForest cmdlet for promotion.

# Promotes the server to a domain controller and creates a new forest.
# Windows Server 2016 and later forest functional level. Adjust if using
# older versions, but I recommend using the latest for new labs.
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
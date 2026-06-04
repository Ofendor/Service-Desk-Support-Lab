# 02-Install-AD-DS,DNS, and DHCP Roles into DC01 Server VM 
# Installs and verifies AD DS, DNS, and DHCP roles, 
# but does not promote the server to a domain controller yet. 
# Helpful for testing and troubleshooting role installation before promotion.

Write-Host "========================================================"
Write-Host "  INSTALLING ROLES INTO Domain Controller 01 SERVER VM  "
Write-Host "========================================================"

Write-Host "`n=== Installing AD DS, DNS, and DHCP ==="
Install-WindowsFeature AD-Domain-Services, DNS, DHCP -IncludeManagementTools

Write-Host "`n=== Verifying Installation. Expected State: Installed ==="
Get-WindowsFeature AD-Domain-Services, DNS, DHCP | Format-Table Name, DisplayName, InstallState

Write-Host "`n=== Installation Complete! :)! Don't forget to take screenshots for your lab! ==="
Write-Host "Next: Run scripts/03-promote-dc.ps1 to promote this server."

# NOTE: You can run this script or prompt the codes by copy and paste alone, 
# but I recommend running the script as a whole to ensure all steps are executed in order.

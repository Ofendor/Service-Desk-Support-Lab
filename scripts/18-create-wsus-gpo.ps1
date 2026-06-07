# ==================================================================
# This script creates a Group Policy Object (GPO) to configure WSUS 
# client settings and links it to the domain. It sets the necessary 
# registry values to point clients to the WSUS server and configures 
# automatic update options. The GPO is then linked to the domain so 
# that it applies to all computers within the domain.
# ==================================================================
# Creates the WSUS Client Configuration GPO and links it to the domain
# Run on AKL-DC01 as SERVICEDESK\Administrator
# ==================================================================
Write-Host "=== Creating WSUS Client Configuration GPO ==="
New-GPO -Name "WSUS Client Configuration" -ErrorAction SilentlyContinue 

Write-Host "=== Setting registry values for WSUS client ==="
Set-GPRegistryValue -Name "WSUS Client Configuration" -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" -ValueName "WUServer" -Type String -Value "http://AKL-DC01:8530"
Set-GPRegistryValue -Name "WSUS Client Configuration" -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" -ValueName "WUStatusServer" -Type String -Value "http://AKL-DC01:8530"
Set-GPRegistryValue -Name "WSUS Client Configuration" -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Type DWord -Value 0
Set-GPRegistryValue -Name "WSUS Client Configuration" -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "AUOptions" -Type DWord -Value 3

Write-Host "=== Linking GPO to domain ==="
New-GPLink -Name "WSUS Client Configuration" -Target "DC=servicedesk,DC=lab" -ErrorAction SilentlyContinue

Write-Host "`n=== WSUS GPO created and linked successfully ==="
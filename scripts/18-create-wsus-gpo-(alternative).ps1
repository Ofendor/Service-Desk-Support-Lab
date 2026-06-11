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
# Alternative version of the script using backticks for line continuation
New-GPO -Name "WSUS Client Configuration" -ErrorAction SilentlyContinue    # Create GPO

# Set WUServer registry value
# Registry key for Windows Update settings
# Name of the registry value to set
# URL of the WSUS server
Set-GPRegistryValue -Name "WSUS Client Configuration" ` 
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" ` 
    -ValueName "WUServer" ` 
    -Type String `
    -Value "http://AKL-DC01:8530" 

# Set WUStatusServer registry value
# Registry key for Windows Update settings
# Name of the registry value to set
# URL of the WSUS server for status reporting
Set-GPRegistryValue -Name "WSUS Client Configuration" ` 
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" ` 
    -ValueName "WUStatusServer" ` 
    -Type String `
    -Value "http://AKL-DC01:8530" 

# Set NoAutoUpdate registry value, because we want to enable automatic updates
# Registry key for Automatic Update settings
# Name of the registry value to set
Set-GPRegistryValue -Name "WSUS Client Configuration" ` 
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" ` 
    -ValueName "NoAutoUpdate" ` 
    -Type DWord `
    -Value 0 

# Set AUOptions registry value to configure automatic update options
# Registry key for Automatic Update settings
Set-GPRegistryValue -Name "WSUS Client Configuration" ` 
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -ValueName "AUOptions" `
    -Type DWord `
    -Value 3 

New-GPLink -Name "WSUS Client Configuration" -Target "DC=servicedesk,DC=lab" -ErrorAction SilentlyContinue # Link GPO to the domain

Write-Host "WSUS Client Configuration GPO created and linked." # Output message to indicate completion
Get-GPLink -Name "WSUS Client Configuration" | Format-Table Target, Enabled # Display the GPO link status for verification

# By doing this, we ensure that all clients in the domain will receive 
# the WSUS configuration settings defined in the GPO, allowing them 
# to communicate with the WSUS server for updates.
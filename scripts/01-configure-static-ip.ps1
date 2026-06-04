# 01-Configure-Static-IP for DC01 Server VM.ps1
# Sets static IP on AKL-DC01 before AD DS installation, ensuring stable network configuration for domain controller role.

$adapter = Get-NetAdapter -Name "Ethernet*" | Select-Object -First 1

# Remove existing IP, if any, to avoid conflicts
Remove-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -Confirm:$false

# Set static IP, adjust IP address as needed
New-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -IPAddress 192.168.xx.xx -PrefixLength 24 -DefaultGateway 192.168.10.1

# Set DNS to localhost, since DC will be its own DNS server
Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses 127.0.0.1

# Verify, display current IP and DNS settings
Write-Host "=== IP Configuration ==="
Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex | Select-Object IPAddress, PrefixLength

Write-Host "=== DNS Configuration ==="
Get-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex

# Note: refer to docs ~/doc/01-initial-server-setup.md file for further instructions

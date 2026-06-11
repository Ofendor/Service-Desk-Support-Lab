<# 
.SYNOPSIS
    Restores the static enterprise network configuration for AKL-DC01.
.DESCRIPTION
    Disables DHCP on the Ethernet adapter first, re-applies the static IP and
    gateway, binds DNS back to the local AD loopback, re-registers the
    DC's A and SRV records, and recycles IIS/WSUS to bind to the
    restored address. 
.EXAMPLE
    .\20-network-restoration-script.ps1
    Run elevated on AKL-DC01 after the temporary NAT/DHCP sync window.       
#>

# 1. DEFINE ENTERPRISE AD LAYOUT VARIABLES
# These parameters should be adjusted to match the specific
# network configuration of the environment you have chosen.
$InterfaceName = "Ethernet" 
$StaticIP      = "192.168.10.10"
$PrefixLength  = 24                 # Subnet Mask 255.255.255.0
$Gateway       = "192.168.10.1"
$DNSServers    = "192.168.10.10","127.0.0.1" # Own IP first, loopback second

Write-Output "[*] Restoring static network parameters for servicedesk.lab..."

# 2. CONFIGURE STATIC IP AND DEFAULT GATEWAY
# DHCP must be explicitly disabled first, and Windows
# will otherwise keep soliciting leases even with a static IP present,
# creating ghost IPv4 addresses and routing issues.
Write-Output "[*] Disabling DHCP on $InterfaceName..."
Set-NetIPInterface -InterfaceAlias $InterfaceName -AddressFamily IPv4 -Dhcp Disabled
#
Write-Output "[*] Clearing existing IPv4 addresses and default route..."
Remove-NetIPAddress -InterfaceAlias $InterfaceName -AddressFamily IPv4 `
    -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceAlias $InterfaceName -DestinationPrefix "0.0.0.0/0" `
    -Confirm:$false -ErrorAction SilentlyContinue
#
Write-Output "[*] Applying static IP $StaticIP/$PrefixLength via $Gateway..."
New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $StaticIP `
    -PrefixLength $PrefixLength -DefaultGateway $Gateway | Out-Null

# 3. POINT DNS BACK TO THE DOMAIN CONTROLLER LOOPBACK
# This ensures that the server will use its own DNS service, which is critical
# for Active Directory functionality.
Write-Output "[*] Re-binding Preferred DNS to internal Active Directory engine..."
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $LocalDNS

# 4. REFRESH NETWORK RECORD CACHES
# Flushing the DNS cache and re-registering the DNS records ensures
# that the new network configuration is properly propagated and that the
# server's identity is correctly advertised on the network.
Write-Output "[*] Registering internal DNS environment records..."
ipconfig /flushdns
ipconfig /registerdns

# 5. CYCLE WEB APP SERVICES TO RE-BIND TO THE NEW IP
# The WSUS service relies on the underlying IIS web server to handle
# incoming requests from client machines.
# Restarting these services ensures that they will bind to the new
# static IP address and be reachable
Write-Output "[*] Restarting web app layer to listen on the local static network..."
Stop-Process -Name w3wp -Force -ErrorAction SilentlyContinue
iisreset /restart
Restart-Service WsusService -Force

Write-Output "[+] Static network recovery routine completed successfully!"
Write-Output "--------------------------------------------------------"
Get-NetIPConfiguration -InterfaceAlias $InterfaceName | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer
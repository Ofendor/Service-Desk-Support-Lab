<# 
.SYNOPSIS
    Restores the static enterprise network configuration for AKL-DC01.
.DESCRIPTION
    Switches the Ethernet adapter back to static IP mode, binds DNS to the local AD loopback, 
    and opens the internal listener for domain workstations.
#>

# 1. DEFINE ENTERPRISE AD LAYOUT VARIABLES
# These parameters should be adjusted to match the specific
# network configuration of the environment you have chosen.
$InterfaceName = "Ethernet" 
$StaticIP      = "192.168.10.10"
$PrefixLength  = 24                 # Equivalent to Subnet Mask 255.255.255.0
$Gateway       = "192.168.10.1"
$LocalDNS      = "127.0.0.1"        # Points to local Active Directory Domain Controller DNS

Write-Output "[*] Restoring static network parameters for servicedesk.lab..."

# 2. CONFIGURE STATIC IP AND DEFAULT GATEWAY
# The script first attempts to set the static IP configuration.
# If the IP address is already assigned to the interface, it will
# throw an error, which is caught and handled by creating a
# new IP address entry with the specified parameters.
try {
    Set-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $StaticIP -PrefixLength $PrefixLength -DefaultGateway $Gateway -ErrorAction Stop
} catch {
    New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $StaticIP -PrefixLength $PrefixLength -DefaultGateway $Gateway -Force
}

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
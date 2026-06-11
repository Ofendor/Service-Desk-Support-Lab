#===============================================================================
# This creates and configures DHCP scope for servicedesk.lab domain.
# It defines the IP address range, subnet mask, 
# default gateway, DNS server, and domain name for DHCP clients.
#===============================================================================
# NOTE: Your VM's adapter 1 should be set to "NAT Network" named "LabNet"
#       (192.168.10.0/24). In VirtualBox: File > Preferences > Network >
#       NAT Networks > LabNet > make sure "Enable DHCP" is UNTICKED.
#       AKL-DC01 is the ONLY DHCP server on this network — VirtualBox's
#       built-in DHCP must stay disabled or clients receive duplicate
#       leases from two different servers.
#===============================================================================
# You can change this to something more descriptive if 
# you have multiple scopes, but make sure to update it 
# in the verification steps as well.
$scopeName = "Servicedesk-Clients" 
$startRange = "192.168.10.100"
$endRange = "192.168.10.200"
$subnetMask = "255.255.255.0"
$router = "192.168.10.1" # This is the default gateway for DHCP clients, adjust if your VM network setup differs.
$dnsServer = "192.168.10.10"
$domainName = "servicedesk.lab"

Write-Host "=== Creating DHCP Scope ==="
# By this, you are creating a DHCP scope named "Servicedesk-Clients" with 
# the specified IP range, subnet mask, and lease duration of 8 days. 
# Adjust the lease duration as needed for your lab environment.
Add-DhcpServerV4Scope `
    -Name $scopeName `
    -StartRange $startRange `
    -EndRange $endRange `
    -SubnetMask $subnetMask `
    -LeaseDuration 8.00:00:00

Write-Host "=== Setting Scope Options ==="
# These options will be provided to DHCP clients when they receive an IP address lease.
Set-DhcpServerV4OptionValue -ScopeId 192.168.10.0 -Router $router
Set-DhcpServerV4OptionValue -ScopeId 192.168.10.0 -DnsServer $dnsServer
Set-DhcpServerV4OptionValue -ScopeId 192.168.10.0 -DnsDomain $domainName

Write-Host "=== Authorizing DHCP Server ==="
# Authorize the DHCP server in Active Directory so it can start leasing IP addresses to clients.
Add-DhcpServerInDC
Restart-Service DHCPServer

Write-Host "`n=== Verification ==="
# Verify that the scope is created and options are set correctly.
Get-DhcpServerv4Scope | Format-Table Name, StartRange, EndRange, State
Get-DhcpServerv4OptionValue -ScopeId 192.168.10.0 | Format-Table OptionId, Name, Value
Get-DhcpServerInDC

Write-Host "`n=== DHCP Configuration Complete ==="
# Note: If any of the expected results do not match, review the previous steps and check 
# for errors during scope creation or Virtual Machine configuration. 
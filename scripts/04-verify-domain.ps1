# After the reboot, run this script to verify that the domain controller is functioning properly.
# This script checks the status of core services (AD DS, DNS, DHCP), 
# retrieves domain information, lists domain controllers, checks DNS zones, and verifies DHCP server status.

Write-Host "============================================"
Write-Host "  DOMAIN CONTROLLER VERIFICATION"
Write-Host "============================================"

Write-Host "`n=== Core Services ===" 
# Expected Status: Running, StartType: Automatic
Get-Service NTDS, DNS, DHCPServer | Format-Table Name, Status, StartType

Write-Host "=== Domain Information ===" 
# Expected DomainMode: WinThreshold, Forest: servicedesk.lab, DNSRoot: servicedesk.lab
Get-ADDomain | Format-Table Name, DomainMode, Forest, DNSRoot

Write-Host "=== Domain Controller ===" 
# Expected: 1 domain controller with correct name, site, IP, and OS.
# For example, Name: DC01, Site: Default-First-Site-Name, 
# IPv4Address: (your server's IP), IsGlobalCatalog: True, OperatingSystem: Windows Server 2019 or later.
Get-ADDomainController | Format-Table Name, Site, IPv4Address, IsGlobalCatalog, OperatingSystem

Write-Host "=== DNS Zones ==="
# Expected: 1 zone named servicedesk.lab, Type: Primary, DynamicUpdate: SecureOnly
Get-DnsServerZone | Format-Table ZoneName, ZoneType, DynamicUpdate

Write-Host "=== DHCP Server Status ==="
# Expected: 1 DHCP server with correct name and IP address.
Get-DhcpServerInDC

Write-Host "`n=== Verification Complete ==="

# NOTE: If any of the expected results do not match, review the previous steps and check 
# for errors during installation or promotion.
# You can also check event logs for troubleshooting.
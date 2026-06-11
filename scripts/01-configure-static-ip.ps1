# Sets static IP on AKL-DC01 before AD DS installation, ensuring 
# stable network configuration for domain controller role.
# A domain controller must have a fixed address and use itself for DNS.
# Safe to re-run (clears old config before applying).

$StaticIP     = "192.168.10.10"
$PrefixLength = 24
$Gateway      = "192.168.10.1"
$DNS          = "127.0.0.1"   # DC will be its own DNS server

$adapter = Get-NetAdapter -Name "Ethernet*" | Select-Object -First 1

Write-Host "=== Disabling DHCP on $($adapter.Name) ==="
Set-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -Dhcp Disabled

Write-Host "=== Clearing existing IPv4 config ==="
Remove-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceIndex $adapter.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "=== Applying static IP $StaticIP ==="
New-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -IPAddress $StaticIP -PrefixLength $PrefixLength -DefaultGateway $Gateway

Write-Host "=== Setting DNS to $DNS ==="
Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses $DNS

Write-Host "`n=== Verification ==="
Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex |
    Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer
Get-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 |
    Select-Object InterfaceAlias, Dhcp   # Expect: Disabled

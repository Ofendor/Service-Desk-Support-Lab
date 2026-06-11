# Initial Server Setup

## Server Details
- **Hostname:** AKL-DC01
- **OS:** Windows Server 2022
- **Role:** Domain Controller
- **Static IP:** 192.168.10.10/24
- **Gateway:** 192.168.10.1
- **DNS:** 127.0.0.1

## Steps Performed

### Guest Additions
- Installed VirtualBox Guest Additions for mouse integration and clipboard sharing.
- Created a shared folder with host machine.

![Install VBox Guest Additions](../screenshots/01-install-vbox-guest-additions.png)
![Add Shared Folder](../screenshots/02-add-shared-folder.png)

### Network Configuration
- Set static IP: `192.168.10.10`
- Configured DNS to point to localhost (127.0.0.1)
- This ensures the server uses itself for DNS after AD DS installation.

![Configure Static IP 1](../screenshots/03-configure-static-IP-1.png)
![Configure Static IP 2](../screenshots/04-configure-static-IP-2.png)
![Configure DNS and Verification](../screenshots/05-configure-DNS-and-verification.png)

## Commands Used

```powershell
# Find the adapter (index varies per machine — don't hardcode it)
$adapter = Get-NetAdapter -Name "Ethernet*" | Select-Object -First 1

# Disable DHCP and set static IP
Set-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -Dhcp Disabled
New-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -IPAddress 192.168.10.10 -PrefixLength 24 -DefaultGateway 192.168.10.1

# Point DNS at itself (required for a future domain controller)
Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses 127.0.0.1
```

## PowerShell Scripts

| Script | Purpose |
|---|---|
| `scripts/01-configure-static-ip.ps1` | Set static IP and DNS on DC01 Server before AD install |
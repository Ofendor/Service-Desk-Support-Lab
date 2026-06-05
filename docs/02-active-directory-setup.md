# Active Directory Domain Services Setup

## Domain Information
- **Domain:** servicedesk.lab
- **NetBIOS Name:** SERVICEDESK
- **Domain Controller:** AKL-DC01
- **IP Address:** 192.168.10.10
- **Functional Level:** Windows Server 2016 (WinThreshold)

## Step 1: Install Roles

### Command

```
Install-WindowsFeature AD-Domain-Services, DNS, DHCP -IncludeManagementTools
```

### Verification

```
Get-WindowsFeature AD-Domain-Services, DNS, DHCP | Format-Table Name, DisplayName, InstallState

# Expected: All three roles show Installed.
```

![Roles Installed](../screenshots/06-roles-installed.png)

## Step 2: Promote to Domain Controller

### Command

Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName "servicedesk.lab" `
    -DomainNetbiosName "SERVICEDESK" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns:$true `
    -CreateDnsDelegation:$false `
    -SafeModeAdministratorPassword (Read-Host "Enter DSRM Password" -AsSecureString) `
    -Force:$true

Server restarts automatically after promotion.

### Post-Reboot Login
- Username: SERVICEDESK\Administrator
- Password: Original Administrator password (not DSRM)

## Step 3: Post-Promotion Verification

### Core Services

Get-Service NTDS, DNS, DHCPServer | Format-Table Name, Status, StartType

Expected: All three services show Running.

### Domain Information

Get-ADDomain | Format-Table Name, DomainMode, Forest, DNSRoot

Expected: Name = servicedesk.lab, DomainMode = Windows2016Domain.

### Domain Controller

Get-ADDomainController | Format-Table Name, Site, IPv4Address, IsGlobalCatalog

Expected: Name = AKL-DC01, IPv4Address = 192.168.10.10, IsGlobalCatalog = True.

### DNS Zones

Get-DnsServerZone | Format-Table ZoneName, ZoneType

Expected: servicedesk.lab with ZoneType Primary.

### DHCP Server Status

Get-DhcpServerInDC

![Domain Verified](../screenshots/06-domain-verified.png)

## Scripts
- [Install AD DS Roles](../scripts/02-install-ad-ds.ps1)
- [Promote Domain Controller](../scripts/03-promote-dc.ps1)
- [Verify Domain](../scripts/04-verify-domain.ps1)

## Next Steps
Proceed to [DHCP Configuration](03-dhcp-configuration.md)
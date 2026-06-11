# Lab Environment Setup

## Hypervisor
- **Software:** Oracle VirtualBox
- **Version:** 7.0 or later

## Network Configuration

### NAT Network
A NAT Network was created to allow all VMs to communicate with each other while maintaining internet access.

| Setting | Value |
|---|---|
| Name | ServicedeskLab |
| Network CIDR | 192.168.10.0/24 |
| DHCP | Disabled (DC01 provides DHCP) |

### Steps to Create
1. File → Preferences → Network → NAT Networks
2. Click Add (+)
3. Name: ServicedeskLab
4. Network CIDR: 192.168.10.0/24
5. OK

## Virtual Machines

### AKL-DC01 (Domain Controller)

| Setting | Value |
|---|---|
| OS | Windows Server 2022 Standard |
| Memory | 2048 MB |
| CPU | 2 vCPUs |
| Disk | 40 GB dynamic VDI |
| Network | NAT Network (ServicedeskLab) |
| IP | 192.168.10.10 (static) |
| Roles | AD DS, DNS, DHCP |

### WIN11-01 (Client)

| Setting | Value |
|---|---|
| OS | Windows 11 Enterprise |
| Memory | 4096 MB |
| CPU | 2 vCPUs |
| Disk | 60 GB dynamic VDI |
| Network | NAT Network (ServicedeskLab) |
| IP | DHCP (192.168.10.100-200) |

### WIN11-01 (Optional)

| Setting | Value |
|---|---|
| OS | Windows 11 Enterprise |
| Memory | 4096 MB |
| CPU | 2 vCPUs |
| Disk | 60 GB dynamic VDI |
| Network | NAT Network (ServicedeskLab) |
| IP | DHCP (192.168.10.100-200) |

## Lab Network Diagram

```mermaid
graph TD
    Internet --- VBox[VirtualBox NAT Network<br>192.168.10.0/24]
    VBox --- DC01[AKL-DC01<br>192.168.10.10<br>AD DS / DNS / DHCP]
    VBox --- W11A[WIN11-01<br>DHCP Client<br>Domain Joined]
    VBox --- W11B[WIN11-02<br>DHCP Client<br>Domain Joined]
``````mermaid
graph TD
    HOST[VirtualBox Host] --- NET[ServicedeskLab NAT Network<br>192.168.10.0/24]

    NET --- DC01[AKL-DC01<br>Windows Server 2022<br>.10 Static]
    DC01 --- AD[AD DS / DNS / DHCP]
    DC01 --- WSUS[WSUS Patch Management]
    DC01 --- FS[File Shares<br>NTFS & Share Perms]
    DC01 --- GPO[Group Policy]

    NET --- W11[WIN11-01<br>Windows 11 Enterprise<br>DHCP .100-.200]
    W11 --- DOMAIN[Domain Joined]
    W11 --- INTUNE[Intune Enrolled]

    NET --- DEBIAN[Debian Linux<br>.20 DHCP Reservation]
    DEBIAN --- OSTICKET[osTicket<br>Ticketing System]

    CLOUD[Cloud Services] --- AZURE[Azure AD / Intune Trial]
    CLOUD --- M365[Microsoft 365 Trial<br>Optional]
```

## Lab overview

```mermaid
graph TD
    HOST[VirtualBox Host] --- NET[ServicedeskLab NAT Network<br>192.168.10.0/24]

    NET --- DC01[AKL-DC01<br>Windows Server 2022<br>25 GB<br>.10 Static]
    DC01 --- AD[AD DS / DNS / DHCP]
    DC01 --- WSUS[WSUS Patch Management]
    DC01 --- FS[File Shares<br>NTFS & Share Perms]
    DC01 --- GPO[Group Policy<br>Password & Lockout]

    NET --- W11[WIN11-01<br>Windows 11 Enterprise<br>30 GB<br>DHCP]
    W11 --- DOMAIN[Domain Joined]
    W11 --- INTUNE[Intune Enrolled]

    NET --- DEBIAN[Debian Linux<br>5-10 GB<br>.20 Static]
    DEBIAN --- OSTICKET[osTicket<br>Ticketing System]

    NET --- W11B[WIN11-02<br>Windows 11 Enterprise<br>30 GB<br>DHCP<br>Optional]

    CLOUD[Cloud Services] --- AZURE[Azure AD / Intune Trial]
    CLOUD --- M365[Microsoft 365 Trial<br>Optional]

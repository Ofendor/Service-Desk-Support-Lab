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

### WIN11-02 (Client - Optional)

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
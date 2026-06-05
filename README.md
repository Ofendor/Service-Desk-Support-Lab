# Service Desk Support Lab
![VirtualBox](https://img.shields.io/badge/VirtualBox-7.0-blue?logo=virtualbox&logoColor=white)
![Windows Server](https://img.shields.io/badge/Windows%20Server-2022%20Evaluation-blue?logo=windows&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows%2011-Enterprise%20Evaluation-blue?logo=windows11&logoColor=white)
![Active Directory](https://img.shields.io/badge/Active%20Directory-Domain%20Services-003366?logo=microsoft&logoColor=white)
![DNS](https://img.shields.io/badge/DNS-Server-003366?logo=windowsterminal&logoColor=white)
![DHCP](https://img.shields.io/badge/DHCP-Server-003366?logo=windowsterminal&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7.4-5391FE?logo=powershell&logoColor=white)
![osTicket](https://img.shields.io/badge/osTicket-1.18%20(Open%20Source)-green?logo=opensourceinitiative&logoColor=white)
![WSUS](https://img.shields.io/badge/WSUS-Built--in-003366?logo=microsoft&logoColor=white)
![Intune](https://img.shields.io/badge/Intune-Free%20Trial-0078D4?logo=microsoftintune&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?logo=github&logoColor=white)
![Markdown](https://img.shields.io/badge/Docs-Markdown-000000?logo=markdown&logoColor=white)
![Mermaid](https://img.shields.io/badge/Diagrams-Mermaid-FF3670?logo=mermaid&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow)

Author: Emilio Mardones

---

## About the lab

This is a hands-on lab that simulates the IT infrastructure you'd find inside a real company. I built it to practise the kind of work a service desk analyst does every day. Once you set up your lab, you will be ready to start managing users, resetting passwords, fixing access issues, implement group policies, do patch management, and manage ticketing services. Everything runs using VirtualBox and free or open-source tools.

---

## Who is this lab for?

Anyone who wants to break into IT support, sharpen their Active Directory skills, or build a portfolio that proves they can actually do the job. By the end you'll have touched nearly every core technology a Level 1 or Level 2 service desk role expects.

---

## Learning path

- Installing Windows Server and promoting it to a Domain Controller
- Configuring DNS and DHCP so your network actually works
- Structuring Active Directory with OUs, Security Groups, and real user accounts
- Everyday help-desk tickets: password resets, account unlocks, onboarding, offboarding, department transfers
- NTFS permissions and shared folders — the right people get in, the wrong ones don't
- PowerShell scripts that automate the boring stuff
- Writing runbooks someone else could follow
- Using a ticketing system to log and track issues properly
- WSUS for patch management to keep servers and workstations up to date
- Enrolling devices into Microsoft Intune for modern device management

---

## Lab Architecture

| VM | OS | Hostname | IP | Role |
|---|---|---|---|---|
| 1 | Windows Server 2022 | AKL-DC01 | 192.168.10.10 | Domain Controller, DNS, DHCP, WSUS |
| 2 | Windows 11 Enterprise | WIN11-01 | DHCP | Domain-joined client |
| 3 | Windows 11 Enterprise (optional) | WIN11-02 | DHCP | Domain-joined client |
| 4 | Debian Linux | Debian-SRV | 192.168.10.20 | osTicket ticketing system |

NOTE: we are using Windows 11 instead of Windows 10 because expired October 2025. I want you to use current software to be familiar with rather than using legacy. Be aware that some companies stiull rely on legacy software these days.

---

## Repository Structure

```mermaid
graph TD
    ROOT[Service-Desk-Support-Lab] --- SCRIPTS[scripts<br>PowerShell automation]
    ROOT --- SHOTS[screenshots<br>Configuration evidence]
    ROOT --- DOCS[docs<br>Step-by-step guides]
    ROOT --- BOOKS[runbooks<br>Help-desk procedures]
    ROOT --- DIAG[diagrams<br>Network topology]
    ROOT --- README[README.md]
```
---

## Documentation

- [Lab Environment Setup](docs/00-lab-environment.md)
- [Initial Server Setup](docs/01-initial-server-setup.md)
- [Active Directory Setup](docs/02-active-directory-setup.md)
- [DHCP Configuration](docs/03-dhcp-configuration.md)
- [Organisational Units](docs/04-organisational-units.md)
- [Groups and Users](docs/05-groups-and-users.md)
- more to come

## PowerShell Scripts

| Script | Purpose |
|---|---|
| [01-configure-static-ip.ps1](scripts/01-configure-static-ip.ps1) | Set static IP and DNS on DC01 |
| [02-install-ad-ds.ps1](scripts/02-install-ad-ds.ps1) | Install AD DS, DNS, DHCP roles |
| [03-promote-dc.ps1](scripts/03-promote-dc.ps1) | Promote server to Domain Controller |
| [04-verify-domain.ps1](scripts/04-verify-domain.ps1) | Post-promotion verification checks |
| [05-configure-dhcp.ps1](scripts/05-configure-dhcp.ps1) | Configure DHCP scope and options |
| [06-create-ous.ps1](scripts/06-create-ous.ps1) | Create Organisational Units |
| [07-create-groups.ps1](scripts/07-create-groups.ps1) | Create Security Groups |
| [08-create-users.ps1](scripts/08-create-users.ps1) | Create 15 users across 3 departments |

## Final Lab Environment Overview

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
```

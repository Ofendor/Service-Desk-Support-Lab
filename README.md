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


## What Is This?

A hands-on lab that simulates the IT infrastructure you'd find inside a real company. I built it to practise the kind of work a service desk analyst does every day — managing users, resetting passwords, fixing access issues, and keeping systems documented. Everything runs on a laptop using VirtualBox and free or open-source tools.

It's designed with a Datacom-style managed services environment in mind: multiple departments, structured processes, and proper documentation.

## Who Is This For?

Anyone who wants to break into IT support, sharpen their Active Directory skills, or build a portfolio that proves they can actually do the job. By the end you'll have touched nearly every core technology a Level 1 or Level 2 service desk role expects.

## What You'll Learn

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

## Tool Scope

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

## Lab Architecture

| VM | OS | Hostname | IP | Role |
|---|---|---|---|---|
| 1 | Windows Server 2022 | AKL-DC01 | 192.168.10.10 | Domain Controller, DNS, DHCP, WSUS |
| 2 | Windows 11 Enterprise | WIN11-01 | DHCP | Domain-joined client |
| 3 | Windows 11 Enterprise | WIN11-02 | DHCP | Domain-joined client |
| 4 | Debian Linux | Debian-SRV | 192.168.10.20 | osTicket ticketing system |

## Repository Structure

```mermaid
graph TD
    ROOT[Service-Desk-Support-Lab] --- SCRIPTS[scripts<br>PowerShell automation]
    ROOT --- SHOTS[screenshots<br>Configuration evidence]
    ROOT --- DOCS[docs<br>Step-by-step guides]
    ROOT --- BOOKS[runbooks<br>Help-desk procedures]
    ROOT --- DIAG[diagrams<br>Network topology]
    ROOT --- README[README.md]
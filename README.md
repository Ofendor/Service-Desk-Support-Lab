# Service-Desk-Support-Lab
Windows Server 2022 lab with Active Directory, DNS, DHCP, and help-desk ticketing simulations.

## Service Desk Architecture for students
servicedesk.lab (VirtualBox)
│
├── AKL-DC01 (Windows Server 2022) - 25 GB
│   ├── AD DS, DNS, DHCP
│   ├── WSUS (patch management)
│   ├── File shares (NTFS/share permissions)
│   └── Group Policy (password policies, lockout)
│
├── WIN11-01 (Windows 11 Enterprise) - 30 GB
│   └── Domain-joined, Intune-enrolled
│
├── Debian-Linux (your existing VM) - 5-10 GB
│   └── osTicket (ticketing system)
│
Cloud:
├── Microsoft Azure AD / Intune trial
└── Microsoft 365 trial (optional, for full Modern Workplace)
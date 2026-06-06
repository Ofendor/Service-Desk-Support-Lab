# Group Policy Configuration

## Overview

Group Policy enforces settings across all domain-joined machines. Three GPOs were created and linked to the domain or specific OUs. Additionally, logon hour restrictions were applied to a single user.

## GPO 1: Password Policy

**Purpose:** Enforce strong password requirements for all users.

| Setting | Value |
|---|---|
| Enforce password history | 5 passwords remembered |
| Maximum password age | 90 days |
| Minimum password age | 1 day |
| Minimum password length | 8 characters |
| Password must meet complexity requirements | Enabled |

**Linked to:** Entire domain (`servicedesk.lab`)

### Creation (PowerShell)
```powershell
New-GPO -Name "Password Policy"
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordHistorySize" -Type DWord -Value 5
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MaximumPasswordAge" -Type DWord -Value 90
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordAge" -Type DWord -Value 1
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordLength" -Type DWord -Value 8
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordComplexity" -Type DWord -Value 1
New-GPLink -Name "Password Policy" -Target "DC=servicedesk,DC=lab"
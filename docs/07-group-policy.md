# Group Policy Configuration

## Overview

Group Policy is the central way to enforce settings on all domain‑joined computers and users.  
Instead of configuring each PC individually, you define a policy once and Windows applies it automatically.

We created three Group Policy Objects (GPOs) and linked them to the domain or a specific OU.  
We also restricted logon hours for one user, Tane Williams, using the GUI.

---

## GPO 1: Password Policy

This policy forces all domain users to use strong passwords. It stops people from using simple passwords
like `password123` or their own name, and prevents them from reusing the same few passwords forever.

### Settings

| Setting | Value | Reason |
|---|---|---|
| Enforce password history | 5 passwords remembered | Users cannot reuse their last 5 passwords. This makes cycling back to an old favourite impossible. |
| Maximum password age | 90 days | Passwords expire after 90 days. Even if someone steals a password, it only works for a limited time. |
| Minimum password age | 1 day | Users must wait 1 day before changing their password again. This stops them from changing it 5 times in a row to get back to the same old password. |
| Minimum password length | 8 characters | Short passwords are easy to guess. 8 is a good minimum balance between security and usability. |
| Password must meet complexity requirements | Enabled | Passwords must contain characters from three of these four groups: uppercase, lowercase, digits, and symbols. |

### Creation and linking

We used PowerShell to create the GPO and set the registry‑based values, then linked it to the entire domain.

```powershell
New-GPO -Name "Password Policy"
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordHistorySize" -Type DWord -Value 5
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MaximumPasswordAge" -Type DWord -Value 90
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordAge" -Type DWord -Value 1
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordLength" -Type DWord -Value 8
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordComplexity" -Type DWord -Value 1
New-GPLink -Name "Password Policy" -Target "DC=servicedesk,DC=lab"
```
If you are using GUI instead, here are the steps to follow. GUI provides a more visual/ granular way of understanding how to implement these policies without making mistakes.

![Creating a password policy](../screenshots/24-create-password-policy-GPO1.png)
*Creating a password policy*

![Setting a password policy](../screenshots/24-create-password-policy-GPO2.png)
*Settings in the password policy*

---
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
**NOTE:** If you are using GUI instead, here are the steps to follow. GUI provides a more visual/ granular way of understanding how to implement these policies without making mistakes.

![Creating a password policy](../screenshots/24-create-password-policy-GPO1.png)
*Creating a password policy*

![Setting a password policy](../screenshots/24-create-password-policy-GPO2.png)
*Settings in the password policy*


![Link password policy to domain GPO](../screenshots/25-link-password-policy-to-domain-GPO.png)
*After setting the password policy, you have to link it to the domain GPO. Same step for the policies below.*

---

## GPO 2: Account Lockout Policy
This policy locks a user account after too many wrong password attempts. It stops attackers from
guessing passwords endlessly (brute‑force attacks). After 15 minutes the account unlocks automatically,
so the service desk doesn't have to unlock it manually for every genuine mistake.

### Settings

| Setting | Value | Reason |
|---|---|---|
| Account lockout threshold | 5 invalid logon attempts | After 5 wrong passwords the account is locked. This is enough tries for a real user who forgot their password, but too few for an attacker. |
| Account lockout duration | 15 minutes | The account stays locked for 15 minutes, then unlocks itself. The user only has to wait, not call the help desk. |
| Reset account lockout counter after | 15 minutes | If the user waits 15 minutes, the failed‑attempt counter goes back to zero. |

### Creation and linking

```powershell
New-GPO -Name "Account Lockout Policy"
Set-GPRegistryValue -Name "Account Lockout Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "LockoutDuration" -Type DWord -Value 15
Set-GPRegistryValue -Name "Account Lockout Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "LockoutBadCount" -Type DWord -Value 5
Set-GPRegistryValue -Name "Account Lockout Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ResetLockoutCount" -Type DWord -Value 15
New-GPLink -Name "Account Lockout Policy" -Target "DC=servicedesk,DC=lab"
```

**NOTE:** If you are using GUI instead, here are the steps to follow. GUI provides a more visual/ granular way of understanding how to implement these policies without making mistakes.

![Creating an account lockout policy](../screenshots/26-create-account-lockout-policy-GPO.png)
*Creating an Account Lockout Policy*

![Linking the Account Lockout Policy into the Domain GPO](../screenshots/27-link-account-policy-to-domain.png)
*Linking the Account Lockout Policy into the Domain GPO*

---

## GPO3: Sales Drive Mapping
This GPO automatically maps the **S:** drive to the `\\AKL-DC01\SalesShare` shared folder for
every user in the **Sales** department. Users don't need to know the network path – the drive just
appears when they log in.

### Real scenario
In a real company, each department usually has a shared folder where they store team files,
reports, and documents. Instead of emailing files back and forth or using USB drives, everyone
saves to the same network location.

By mapping it to a drive letter (S: for Sales), we make it feel like a local folder on their
computer. The user just opens File Explorer, clicks the S: drive, and their team's files are there.

Later in this lab, we will use this same shared folder for **help‑desk ticket simulations**:
- **Ticket 006 – Shared Folder Access:** We will test that Sales users can access the folder,
  but HR and IT users cannot. This proves the permissions are working correctly.
- **NTFS permissions practice:** We will modify permissions on subfolders to grant or deny
  access to specific groups, which is one of the most common requests a service desk analyst
  handles ("I can't open this folder", "Please give the new starter access to the team drive").

Only Sales users need the Sales share. HR and IT users won't see the drive, which keeps the
environment tidy and secure. If an HR user logs in, the S: drive simply doesn't exist for them.

### Prerequisite – Create the shared folder

```powershell
New-Item -Path "C:\Shares\Sales" -ItemType Directory
New-SmbShare -Name "SalesShare" -Path "C:\Shares\Sales" -FullAccess "SERVICEDESK\Sales_Group"
Get-SmbShare -Name "SalesShare"
```

![Creating a shared folder for Sales department: Disk S:/](../screenshots/29-creating-sales-shared-folder.png)
*Creating a shared folder for Sales department: Disk S:/*

---

#### Drive map configuration (GUI guide)

Drive mapping preferences cannot be fully set in PowerShell. We used the GUI:

- Action: Update
- Location: \\AKL-DC01\SalesShare
- Reconnect: Enabled
- Label: Sales Drive
- Drive Letter: S:

![Creating Sales drive 'S:' mapping for GPO/](../screenshots/29-create-sales-drive-mapping-GPO1.png)
*Creating Sales drive 'S:' mapping for GPO*
![Setting configurations for Sales drive 'S:' and mapping for GPO/](../screenshots/29-create-sales-drive-mapping-GPO2.png)
*Setting configurations for Sales drive 'S:' and then mapping into GPO*

After creating the GPO, we linked it to the Sales OU:

```powershell
New-GPO -Name "Sales Drive Mapping"
New-GPLink -Name "Sales Drive Mapping" -Target "OU=Sales,DC=servicedesk,DC=lab"
```

If you get this message, no worries. It means your GUI set up has been successful.

```powershell
PS C:\Users\Administrator> New-GPLink -Name "Sales Drive Mapping" -Target "OU=Sales,DC=servicedesk,DC=lab"
New-GPLink : The GPO named 'Sales Drive Mapping' is already linked to a Scope of Management with Path 'OU=Sales,DC=servicedesk,DC=lab'.
At line:1 char:1
+ New-GPLink -Name "Sales Drive Mapping" -Target "OU=Sales,DC=servicede ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Group...ewGPLinkCommand:NewGPLinkCommand) [New-GPLink], ArgumentException
    + FullyQualifiedErrorId : UnableToCreateNewLink,Microsoft.GroupPolicy.Commands.NewGPLinkCommand

PS C:\Users\Administrator> New-GPO -Name "Sales Drive Mapping"
New-GPO : The command cannot be completed because a "Sales Drive Mapping" GPO already exists in the servicedesk.lab domain.
Parameter name: Sales Drive Mapping
At line:1 char:1
+ New-GPO -Name "Sales Drive Mapping"
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Group...s.NewGpoCommand:NewGpoCommand) [New-GPO], ArgumentException
    + FullyQualifiedErrorId : GpoWithNameAlreadyExists,Microsoft.GroupPolicy.Commands.NewGpoCommand
```

## Final Verification Step
After the previous steps. move to WIN11-01 Virtual Machine and log-in using William Tane credentials. The password is going to be the same as the WIN11-01 VM. DUe to Password Policy previously set up, a new password assignation screen will pop up. Assign a new password, log in an Force Group Policy update on a client.

![Loggin WIN11-01 with a Sales user credentials/](../screenshots/30-1-loggin-tane-williams.png)
*Loggin WIN11-01 with a Sales user credentials*

![Forcing group policy update on a client/](../screenshots/30-updating-policies-WIN11-01.png)
*Forcing group policy update on a client*

After running `gpupdate /force` and restarting WIN11‑01, the S: drive appears for any Sales user (William is one of them).

Have in mind that creating the GPO on the server is only half the job. Group Policy does not
apply instantly because it refreshes on a schedule (every 90 minutes by default, plus a random offset).
In a real service desk environment, you would never ask a user to wait up to two hours for a
change to take effect.

Running `gpupdate /force` tells the client to pull down every GPO immediately. The restart
ensures that settings which only apply at boot or login (like drive mappings) are fully processed.

We then log in as a Sales user to confirm the drive appears, and log in as a non‑Sales user to
confirm it does not. This is the same verification step you would perform before closing a ticket:
*"I've made the change — now let me prove it works before I tell the user it's done."*

Finally, after rebooting, logging with William Tane credentials again and confirm the **'S:/'** drive is visible.

![William Tane confirming 'S:' drive presence/](../screenshots/30-2-drive-mapping-working-tane-williams.png)
*William Tane confirming 'S:' drive presence*

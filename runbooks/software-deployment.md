# Runbook – Software Deployment via GPO

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01 (domain controller), domain-joined clients
**Related Ticket:** [Software Deployment via GPO (7-Zip)](../tickets/ticket-009-software-deployment-gpo.md)

---

## Purpose

Deploy third-party software to domain machines automatically using GPO Software Installation. Use for any "install this app on these machines" request where an `.msi` is available.

> **WSUS vs GPO Software Installation:** WSUS patches Microsoft products only. Third-party applications are deployed through **GPO Software Installation** — a built-in Active Directory feature. Don't confuse the two.

---

## ⚠️ Read First — The Three Things That Break This

Most GPO software deployments fail for one of these reasons. Each has a pre-flight check below:

1. **Package referenced by a local path instead of a UNC path** → error **1612 (source absent)**. The client looks on its own drive and fails.
2. **Windows client using async (Fast Logon) policy processing** → the boot-time install is silently skipped.
3. **GPO linked to the wrong OU** → computer-assigned software follows the *computer* object's OU, not the user's department.

---

## Requirements

- The software must be a **`.msi`** package (not `.exe`). GPO Software Installation only accepts MSI.
- The MSI must sit on a **network share** the target *computers* can read.
- Decide **Assigned to computers** (installs at startup, all users) — the standard approach for machine-wide software.

---

## Step 1: Stage the MSI on a Network Share

Create a folder, place the MSI, and share it with **Domain Computers** read access — the computer account performs the install, not the user.

```powershell
New-Item -Path "C:\Software" -ItemType Directory -Force
Copy-Item "C:\Path\To\installer.msi" -Destination "C:\Software\"
New-SmbShare -Name "Software" -Path "C:\Software" -ReadAccess "Domain Computers","Domain Users"
```

**Verify share permissions include Domain Computers:**
```powershell
Get-SmbShareAccess -Name "Software"
```

> If the share already exists (reusing it for another app), just copy the new MSI in — no need to recreate the share.

---

## Step 2: Confirm the UNC Path Resolves

This is the exact path the GPO will use. It **must** be reachable by UNC, not just locally.

```powershell
Test-Path "\\AKL-DC01\Software\installer.msi"
```
**Expected:** `True`.

> Note: this only proves the *share* works. It does **not** guarantee the GPO will store the right path — that's checked separately in Step 5.

---

## Step 3: Create and Populate the GPO

1. **Group Policy Management** → right-click **Group Policy Objects → New** → name it (e.g. `Deploy <AppName>`).
2. Right-click the GPO → **Edit**.
3. Navigate: **Computer Configuration → Policies → Software Settings → Software installation**.
4. Right-click **Software installation → New → Package…**
5. **CRITICAL:** in the File name box, **type the UNC path** — do NOT browse to the local `C:\Software`:
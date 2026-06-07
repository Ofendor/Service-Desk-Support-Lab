# Logon Hours Restrictions

## Overview

Logon hours control **when** a user account is allowed to sign in to the domain.  
It is a simple but effective security control used for:

- Shift workers who only need access during rostered hours
- Temporary contractors with limited engagement windows
- Service accounts that should only run during maintenance windows
- Compliance requirements (e.g. "no logins outside business hours")

This runbook covers the **basic scenario**: applying logon hours to a single user.  
A bulk department‑wide script is available as a reference for scale operations. 
A Runbook is a compilation of routine procedures and operations that are documented for reference while working on a critical incident. Sometimes, it can also be referred to as a Playbook

---

## Scenario: Single User Restriction

**Request:** Management wants Tane Williams (Sales) restricted to **Monday–Friday, 9:00 AM – 2:00 PM** only. He should not be able to log in outside those hours.

---

## Method 1: GUI

### Steps

1. On **AKL-DC01**, open **Active Directory Users and Computers**
2. Navigate to the **Sales** OU
3. Right‑click **Tane Williams** → **Properties**
4. Go to the **Account** tab
5. Click **Logon Hours**
6. Click and drag to select **Monday through Friday, 9 AM to 2 PM**
7. Click **Logon Permitted**
8. Select all other hours (including Saturday and Sunday) and click **Logon Denied**
9. Click **OK** → **Apply** → **OK**

### Visual Guide

![Single-user Logon hours setting using GUI steps](../screenshots/31-single-user-logon-hours-setting-GUI.png)
*Single-user Logon hours setting using GUI steps.*
*The grid shows allowed hours in blue and denied hours in white. Tane can only log in Monday–Friday between 9:00 AM and 2:00 PM.*

---

## Method 2: PowerShell

### Single User Command

```powershell
# Set logon hours for Tane Williams: Mon-Fri 9:00 AM - 2:00 PM
$hours = @(
    0x00,0x00, # Sunday     - no access
    0xFC,0xFC, # Monday     - 9am-2pm
    0xFC,0xFC, # Tuesday    - 9am-2pm
    0xFC,0xFC, # Wednesday  - 9am-2pm
    0xFC,0xFC, # Thursday   - 9am-2pm
    0xFC,0xFC, # Friday     - 9am-2pm
    0x00,0x00  # Saturday   - no access
)
```

```powershell
Set-ADUser -Identity tane.williams -LogonHours $hours
```

### How the Byte Array Works

The logon hours are stored as a 21‑byte array (3 bytes per day × 7 days). Each bit represents one hour:

| Bit Position | Hour |
|---|---|
| 0 | 00:00–01:00 |
| 1 | 01:00–02:00 |
| ... | ... |
| 23 | 23:00–00:00 |

`0xFC` in binary is `11111100`, which means hours 2 through 7 are allowed and hours 0‑1 are denied. With three bytes per day, we get the full 24‑hour coverage.

### Verification
Check the user's current logon hours:

```powershell
Get-ADUser -Identity tane.williams -Properties LogonHours | Select-Object -ExpandProperty LogonHours
```

---

## What Happens When a User Is Outside Their Allowed Hours

| Situation | Result |
|---|---|
| User tries to log in outside allowed hours | "Your account has time restrictions that prevent you from signing in" |
| User is already logged in when hours end | A warning appears and they are forced off within a few minutes |
| User tries to unlock a locked session | Denied if outside allowed hours |

## Service Desk Troubleshooting

If a user reports "I can't log in" during what should be their working hours:

1. Check the **Logon Hours** grid on their account
2. Verify the **system time** on the client machine — a wrong time zone can cause false denials
3. Confirm with their **manager** what hours they should have
4. Adjust the hours if the request is approved

## Scripts

- [Set Single User Logon Hours](../scripts/15-set-logon-hours.ps1)

## Next Steps

This runbook covers the **single‑user** case. When a management request comes in for all departments (Ticket 007 later in this lab), the bulk script will be used.
- [Bulk Department Logon Hours (reference only)](../scripts/16-set-department-logon-hours.ps1)
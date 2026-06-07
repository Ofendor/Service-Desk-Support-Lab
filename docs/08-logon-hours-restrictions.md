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

![Logon Hours grid for Tane Williams](../screenshots/19-logon-hours.png)
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

Set-ADUser -Identity tane.williams -LogonHours $hours
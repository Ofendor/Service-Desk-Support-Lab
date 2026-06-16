# Ticket 001 – New Employee Onboarding

![Type](https://img.shields.io/badge/Type-Service%20Request-blue)
![Priority](https://img.shields.io/badge/Priority-Normal-green)
![Status](https://img.shields.io/badge/Status-Resolved-success)

**Ticket ID:** #734023 (osTicket)
**Date:** June 2026
**Requester:** James Kereama (HR)
**Assigned To:** Hiroshi Tanaka (Service Desk)
**Help Topic:** New Starter / Leaver
**SLA:** Standard – 24h

---

## Request

HR submitted a request via the Support Center to provision an Active Directory account for a new Sales hire starting Monday.

> *"Kia Ora Hiroshi, Please create an AD account for Emma Wilson. She starts Monday in the Sales department. Regards, James Kereama - HR Department"*

| Field | Detail |
|---|---|
| Full Name | Emma Wilson |
| Department | Sales |
| Job Title | Sales Representative |
| Logon Name | `emma.wilson` |
| UPN | `emma.wilson@servicedesk.lab` |

<!-- SCREENSHOT: osTicket ticket #734023 as submitted by James Kereama (client portal view) -->
![Ticket 001 request](../screenshots/51-ticket001-osticket-request.png)
*The onboarding request as logged in osTicket by HR.*

---

## Why This Matters at an MSP

At a managed services provider like Datacom, onboarding is one of the most frequent ticket types. Getting it wrong has real consequences:

- **Wrong OU** → department GPOs don't apply (e.g. the Sales S: drive mapping won't work).
- **Missing group** → no access to department shared resources on day one.
- **No forced password change** → the service desk retains a working credential, a security gap.

---

## Resolution — PowerShell (AKL-DC01)

### Step 1: Pre-check for duplicate account

```powershell
Get-ADUser -Filter {SamAccountName -eq "emma.wilson"} | Select-Object Name, Enabled
```

Returned nothing — safe to proceed.

### Step 2: Create the account

```powershell
$securePass = ConvertTo-SecureString "<TempPassword>" -AsPlainText -Force

New-ADUser `
    -Name "Emma Wilson" `
    -SamAccountName "emma.wilson" `
    -UserPrincipalName "emma.wilson@servicedesk.lab" `
    -GivenName "Emma" `
    -Surname "Wilson" `
    -DisplayName "Emma Wilson" `
    -Department "Sales" `
    -Title "Sales Representative" `
    -Path "OU=Sales,DC=servicedesk,DC=lab" `
    -AccountPassword $securePass `
    -ChangePasswordAtLogon $true `
    -Enabled $true
```

> `-Path` places Emma in the Sales OU so the Sales GPOs (including the S: drive mapping) apply automatically.
> `-ChangePasswordAtLogon $true` forces her to set her own password at first logon, invalidating the temporary one the service desk used.

### Step 3: Add to the Sales security group

```powershell
Add-ADGroupMember -Identity "Sales_Group" -Members "emma.wilson"
```

> OU placement controls GPOs; group membership controls resource access (shared folders, applications). Both are required — one does not imply the other.

### Step 4: Verify

```powershell
# Confirm account is enabled and in the correct OU
Get-ADUser -Identity emma.wilson -Properties Department, Title |
    Format-Table Name, SamAccountName, Enabled, Department, DistinguishedName

# Confirm group membership from the user side
Get-ADPrincipalGroupMembership -Identity emma.wilson | Select-Object Name
```

**Result:**
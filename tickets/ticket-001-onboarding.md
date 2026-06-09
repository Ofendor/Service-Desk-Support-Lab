# Ticket 001 – New Employee Onboarding

**Ticket ID:** TKT-001
**Date:** June 2026
**Requester:** HR Department
**Assigned To:** Service Desk Analyst
**Priority:** Medium
**Status:** ✅ Resolved

---

## Request

HR submitted a request to provision an Active Directory account for a new Sales department employee starting today.

| Field | Detail |
|---|---|
| Full Name | Emma Wilson |
| Department | Sales |
| Job Title | Sales Representative |
| Logon Name | `emma.wilson` |
| UPN | `emma.wilson@servicedesk.lab` |

---

## Why This Matters at an MSP

At a managed services provider like Datacom, onboarding is one of the most frequent ticket types. Getting it wrong has real consequences:

- Wrong OU = GPOs don't apply (e.g. the Sales S: drive mapping won't work).
- Missing group = no access to department shared resources on day one.
- No forced password reset = service desk knows a working credential — a security gap.

---

## Pre-Checks (run before creating anything)

```powershell
# Confirm no duplicate account already exists
Get-ADUser -Filter {SamAccountName -eq "emma.wilson"} | Select-Object Name, Enabled
```

If the command returns nothing, proceed. If it returns a result, stop and raise with your manager — do not create a duplicate.

---

## Resolution — PowerShell (AKL-DC01)

### Step 1: Create the account

```powershell
$securePass = ConvertTo-SecureString "P@ssW0rd!" -AsPlainText -Force

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

> `-Path` places the user under the Sales OU so the Sales GPOs (including the S: drive mapping) apply automatically.
> `-ChangePasswordAtLogon $true` forces the user to set their own password at first logon, invalidating the temp password the service desk used.

<!-- SCREENSHOT: PowerShell after New-ADUser runs with no errors -->
![Ticket 001 – user created](../screenshots/42-ticket001-ps-create.png)
*`New-ADUser` completed on AKL-DC01 with no errors*

### Step 2: Add to Sales security group

```powershell
Add-ADGroupMember -Identity "Sales_Group" -Members "emma.wilson"
```

> OU placement and group membership are separate things. The OU controls GPOs; the group controls resource access (shared folders, applications). Both are required.

### Step 3: Verify

```powershell
# Confirm account is enabled and in the correct OU
Get-ADUser -Identity emma.wilson -Properties Department, Title |
    Format-Table Name, SamAccountName, Enabled, Department, DistinguishedName

# Confirm group membership from the user side
Get-ADPrincipalGroupMembership -Identity emma.wilson |
    Select-Object Name
```

**Expected output:**

```
Name         SamAccountName Enabled Department DistinguishedName
----         -------------- ------- ---------- -----------------
Emma Wilson  emma.wilson       True Sales      CN=Emma Wilson,OU=Sales,DC=servicedesk,DC=lab

Name
----
Domain Users
Sales_Group
```

<!-- SCREENSHOT: PowerShell showing both verification commands and their output -->
![Ticket 001 – verification](../screenshots/43-ticket001-ps-verify.png)
*Verification confirms enabled status, correct OU, and Sales_Group membership*

---

## Resolution — GUI Alternative (ADUC)

Use this path to cross-check or if PowerShell is unavailable:

1. **Server Manager → Tools → Active Directory Users and Computers**
2. Expand `servicedesk.lab` → click the **Sales** OU
3. Right-click blank space → **New → User**
4. First name: `Emma` / Last name: `Wilson` / User logon name: `emma.wilson` → **Next**
5. Password: `P@ssW0rd!` → tick **"User must change password at next logon"** → **Next → Finish**
6. Double-click Emma → **General** tab → set Department: `Sales`, Title: `Sales Representative`
7. **Member Of** tab → **Add** → type `Sales_Group` → **Check Names → OK → Apply**

<!-- SCREENSHOT: ADUC with Sales OU open, Emma Wilson visible -->
![Ticket 001 – ADUC Sales OU](../screenshots/44-ticket001-aduc-ou.png)
*Emma Wilson visible in the Sales OU in Active Directory Users and Computers*

<!-- SCREENSHOT: Emma's Properties → Member Of tab showing Sales_Group -->
![Ticket 001 – group membership ADUC](../screenshots/45-ticket001-aduc-memberof.png)
*Member Of tab confirming Sales_Group assignment*

---

## osTicket Log Entry

1. Open `http://support.servicedesk.lab:8081/scp`
2. **New Ticket:**
   - **Subject:** New Employee Onboarding – Emma Wilson
   - **Priority:** Normal
   - **Details:** New Sales department employee starting today. Provision AD account.
3. After completing steps 1–3 above, update the ticket:
   > AD account `emma.wilson` created in `OU=Sales`. Added to `Sales_Group`. Temporary password set with forced reset at next logon. Verified via PowerShell — enabled, correct OU, group confirmed.
4. Set status → **Resolved**.

---

## Lessons Learned

- OU placement and group membership must both be completed — one does not imply the other.
- Always run the pre-check for duplicate accounts before creation.
- Verify with `Get-ADPrincipalGroupMembership` rather than filtering `Get-ADGroupMember` — the result is unambiguous.

---

## Related

- [User Onboarding Runbook](../runbooks/user-onboarding.md)
# Runbook – User Onboarding

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01
**Related Ticket:** [#734023 – Onboarding](../tickets/ticket-001-onboarding.md)

---

## Purpose

Standard procedure for provisioning a new user account in Active Directory. Follow this for every onboarding request before touching any configuration.

---

## Pre-Checks

```powershell
# Confirm target OU exists 
Get-ADOrganizationalUnit -Filter {Name -eq "<Department>"} | Select-Object DistinguishedName

# Confirm target group exists
Get-ADGroup -Identity "<Department>_Group" | Select-Object Name, GroupScope

# Confirm no duplicate account
Get-ADUser -Filter {SamAccountName -eq "<firstname.lastname>"} | Select-Object Name, Enabled
```

All three must return expected results before proceeding.

---

## Step 1: Create the User Account

```powershell
$securePass = ConvertTo-SecureString "<TempPassword>" -AsPlainText -Force

New-ADUser `
    -Name "<Full Name>" `
    -SamAccountName "<firstname.lastname>" `
    -UserPrincipalName "<firstname.lastname>@servicedesk.lab" `
    -GivenName "<First>" `
    -Surname "<Last>" `
    -DisplayName "<Full Name>" `
    -Department "<Department>" `
    -Title "<Job Title>" `
    -Path "OU=<Department>,DC=servicedesk,DC=lab" `
    -AccountPassword $securePass `
    -ChangePasswordAtLogon $true `
    -Enabled $true
```

---

## Step 2: Assign to Security Group

```powershell
Add-ADGroupMember -Identity "<Department>_Group" -Members "<firstname.lastname>"
```

---

## Step 3: Verify

```powershell
Get-ADUser -Identity <firstname.lastname> -Properties Department, Title |
    Format-Table Name, SamAccountName, Enabled, Department, DistinguishedName

Get-ADPrincipalGroupMembership -Identity <firstname.lastname> | Select-Object Name
```

**Pass criteria:** `Enabled = True`, DistinguishedName contains the correct OU, group list includes `<Department>_Group`.

---

## Step 4: Update the Ticket

- Add a resolution note with account name, OU, group assigned, and verification result.
- Set status to **Resolved**.

---

## OU and Group Reference

| Department | OU | Group |
|---|---|---|
| Sales | `OU=Sales,DC=servicedesk,DC=lab` | `Sales_Group` |
| HR | `OU=HR,DC=servicedesk,DC=lab` | `HR_Group` |
| IT | `OU=IT,DC=servicedesk,DC=lab` | `IT_Group` |

---

## Notes

- Temporary passwords must satisfy the domain password policy (8+ chars, complexity enabled).
- Always use `-ChangePasswordAtLogon $true` — never leave a service-desk-known password active.
- If the user needs a shared drive mapped immediately, confirm the correct GPO is linked to their OU before they log in.
# Runbook – Department Transfer

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01
**Related Ticket:** [Department Transfer](../tickets/ticket-004-department-transfer.md)

---

## Purpose

Move a user between departments — updating both resource access (groups) and policy scope (OU). Use for any "X is moving from team A to team B" request.

---

## Step 1: Capture Current State

```powershell
Get-ADUser -Identity <username> -Properties Department |
    Format-Table Name, Department, DistinguishedName
Get-ADPrincipalGroupMembership -Identity <username> | Select-Object Name
```

Record the current OU and groups before changing anything.

---

## Step 2: Swap Group Membership

```powershell
Remove-ADGroupMember -Identity "<OldDept>_Group" -Members "<username>" -Confirm:$false
Add-ADGroupMember    -Identity "<NewDept>_Group" -Members "<username>"
```

---

## Step 3: Move to the New OU

```powershell
Move-ADObject `
    -Identity (Get-ADUser -Identity <username>).DistinguishedName `
    -TargetPath "OU=<NewDept>,DC=servicedesk,DC=lab"
```

---

## Step 4: Update the Department Attribute

```powershell
Set-ADUser -Identity <username> -Department "<NewDept>"
```

---

## Step 5: Verify

```powershell
Get-ADUser -Identity <username> -Properties Department |
    Format-Table Name, Department, DistinguishedName
Get-ADPrincipalGroupMembership -Identity <username> | Select-Object Name
```

**Pass criteria:** new OU, new group, old group gone, Department updated.

---

## Department Reference

| Department | OU | Group |
|---|---|---|
| Sales | `OU=Sales,DC=servicedesk,DC=lab` | `Sales_Group` |
| HR | `OU=HR,DC=servicedesk,DC=lab` | `HR_Group` |
| IT | `OU=IT,DC=servicedesk,DC=lab` | `IT_Group` |

---

## Notes

- **Remove the old group** — don't just add the new one. Least privilege.
- OU placement drives GPOs; group membership drives resource access. Both must change.
- Changes apply at the user's next logon / `gpupdate`.
- GUI: ADUC → Member Of (swap groups), Move… (change OU), Organization tab (department).
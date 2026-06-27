# Runbook – Employee Offboarding

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01
**Related Ticket:** [Offboarding](../tickets/ticket-005-offboarding.md)

---

## Purpose

Revoke a departing employee's access safely and reversibly. Use for any leaver. **Disable, don't delete** — deletion comes later, after retention.

---

## Step 1: Confirm the Account

```powershell
Get-ADUser -Identity <username> -Properties Enabled |
    Format-Table Name, Enabled, DistinguishedName
```

---

## Step 2: Disable Immediately

```powershell
Disable-ADAccount -Identity <username>
```

This is the priority action — it blocks all access at once. On involuntary departures, do this the moment HR confirms.

---

## Step 3: Record, Then Remove Group Access

```powershell
# Capture for the audit trail BEFORE removing
Get-ADPrincipalGroupMembership -Identity <username> | Select-Object Name

Remove-ADGroupMember -Identity "<Dept>_Group" -Members "<username>" -Confirm:$false
```

---

## Step 4: Quarantine in Disabled Users OU

```powershell
Move-ADObject `
    -Identity (Get-ADUser -Identity <username>).DistinguishedName `
    -TargetPath "OU=Disabled Users,DC=servicedesk,DC=lab"
```

---

## Step 5: Verify

```powershell
Get-ADUser -Identity <username> -Properties Enabled |
    Format-Table Name, Enabled, DistinguishedName
```

**Pass criteria:** `Enabled = False`, located in `OU=Disabled Users`.

---

## Step 6: Retention & Deletion (later)

- Leave the disabled account in the Disabled Users OU for the retention period (e.g. 30–90 days).
- After retention, and once any file/mailbox handover is complete, delete:
```powershell
  Remove-ADUser -Identity <username> -Confirm:$false
```

---

## Notes

- **Disable ≠ delete.** Disabling preserves the SID so permissions and file ownership survive for handover; it's reversible.
- Revoke access immediately; do the tidy-up (groups, OU) right after.
- Always record group membership before stripping it.
- GUI: ADUC → **Disable Account**, remove groups (Member Of), **Move…** to Disabled Users.
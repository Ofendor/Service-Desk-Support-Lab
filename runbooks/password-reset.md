# Runbook – Password Reset

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01
**Related Ticket:** [#103534 – Password Reset](../tickets/ticket-002-password-reset.md)

---

## Purpose

Standard procedure for resetting a user's forgotten password. Use this for any "I can't log in / forgot my password" request, after verifying the requester's identity.

---

## Verify Identity

Before resetting anything, confirm the requester is who they claim to be (in production: callback to a known number, employee ID, manager confirmation). A reset handed to the wrong person is a security incident.

---

## Step 1: Confirm Account State

```powershell
Get-ADUser -Identity <username> -Properties LockedOut, Enabled, PasswordLastSet |
    Format-Table Name, Enabled, LockedOut, PasswordLastSet
```

- `LockedOut = True` → also unlock (see Account Unlock runbook).
- `Enabled = False` → the account is disabled; do not reset without confirming it should be active.

---

## Step 2: Reset the Password

```powershell
$newPass = ConvertTo-SecureString "<TempPassword>" -AsPlainText -Force
Set-ADAccountPassword -Identity <username> -Reset -NewPassword $newPass
```

---

## Step 3: Force Change at Next Logon

```powershell
Set-ADUser -Identity <username> -ChangePasswordAtLogon $true
```

---

## Step 4: Verify

`ChangePasswordAtLogon` is write-only and cannot be read back. Verify via `pwdLastSet` (0 = must change at next logon):

```powershell
Get-ADUser -Identity <username> -Properties PasswordLastSet, pwdLastSet |
    Select-Object Name, PasswordLastSet,
        @{Name='MustChangeAtLogon';Expression={$_.pwdLastSet -eq 0}}
```

**Pass criteria:** `MustChangeAtLogon = True` (`pwdLastSet = 0`).

---

## Step 5: Deliver & Close

- Deliver the temporary password through a **separate, verified channel** — never in the ticket thread.
- Update the ticket with a resolution note and set status to **Resolved**.

---

## Notes

- `-Reset` does not require the old password — correct for forgotten-password cases.
- The temp password must satisfy the domain password policy (8+ chars, complexity).
- A reset does **not** unlock a locked account — check `LockedOut` and unlock separately if needed.
- GUI path: ADUC → user → **Reset Password** → tick "must change at next logon".
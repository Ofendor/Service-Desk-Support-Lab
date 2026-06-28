# Runbook – Account Unlock

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01
**Related Ticket:** [Account Unlock](../tickets/ticket-003-account-unlock.md)

---

## Purpose

Standard procedure for unlocking an account locked by the domain lockout policy. Use this for any "my account is locked / it won't let me in after several tries" request.

---

## Verify Identity

Confirm the requester is who they claim to be before unlocking. An unlock handed to the wrong person is a security incident.

---

## Step 1: Confirm the Lock & Check History

```powershell
Get-ADUser -Identity <username> -Properties LockedOut, badPwdCount, AccountLockoutTime |
    Format-Table Name, LockedOut, badPwdCount, AccountLockoutTime
```

- `LockedOut = True` → proceed to unlock.
- `LockedOut = False` → the account isn't locked; the issue is something else (forgotten password? disabled account?). Don't unlock blindly.

List all currently locked accounts:

```powershell
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, LockedOut
```

---

## Step 2: Unlock

```powershell
Unlock-ADAccount -Identity <username>
```

> Clears the lockout flag only — the password is unchanged.

---

## Step 3: Verify

```powershell
Get-ADUser -Identity <username> -Properties LockedOut |
    Format-Table Name, LockedOut
```

**Pass criteria:** `LockedOut = False`.

---

## Step 4: Investigate Repeat Lockouts

If the user has been locked out more than once recently, find the source before closing:

- Old password cached on a **phone** (email/Wi-Fi), a **mapped drive**, a **scheduled task**, or a **saved RDP session** retrying against AD.
- Ask the user what changed recently (new phone, recent password change).
- A single unlock without finding the source just delays the next lockout.

---

## Step 5: Close

- Update the ticket with a resolution note (cause if known, and that the account was unlocked).
- Set status to **Resolved**.

---

## Notes

- **Unlock vs. reset:** unlock = account frozen by policy, password still valid. Reset = password forgotten/invalid. If both apply, unlock *and* reset.
- The lockout policy auto-unlocks after the lockout duration, but unlocking manually saves the user the wait.
- GUI path: ADUC → user → **Properties → Account tab → tick "Unlock account" → Apply**.
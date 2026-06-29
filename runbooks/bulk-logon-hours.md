# Runbook – Bulk Logon Hours Assignment

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01
**Related Ticket:** [Bulk Logon Hours](../tickets/ticket-007-bulk-logon-hours.md)
**Script:** [16-set-department-logon-hours.ps1](../scripts/16-set-department-logon-hours.ps1)
**Related Doc File:** [Setting Logon hours restrictions for a single user](docs/08-logon-hours-restrictions.md)

---

## Purpose

Apply logon-hour restrictions across one or more departments at once, via script — including per-department core hours and optional weekend exceptions for individual users. Use for any "apply these working hours to department(s)" request.

---

## ⚠️ Read First: logonHours Is Stored in UTC

Active Directory stores the `logonHours` attribute in **UTC**, not local time. If you write local hours directly, the ADUC Logon Hours grid displays them shifted by your local UTC offset — and hours that cross midnight in UTC will wrap onto adjacent days, making the schedule look wrong.

This script converts the specified **local** hours to UTC before writing, using a `$UtcOffset` parameter. You supply your offset; the script does the conversion so the grid shows the intended local times.

**Set `$UtcOffset` to your own timezone's offset from UTC:**

| Location | Offset |
|---|---|
| New Zealand – winter (NZST) | `12` |
| New Zealand – summer (NZDT) | `13` |
| Sydney (AEST) | `10` |
| UK (GMT) | `0` |
| US Eastern (EST) | `-5` |
| US Pacific (PST) | `-8` |

> **Anyone reusing this lab from another country:** this is the one value you must change. Find your current UTC offset and pass it with `-UtcOffset`. If your region observes daylight saving, the offset changes by season — use the value for the current period.

---

## Step 1: Allow the Script to Run

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Session-scoped — reverts when the window closes. Preferred over changing the machine-wide policy.

---

## Step 2: Clear Existing Logon Hours (Clean Slate)

Before applying a new schedule, reset everyone to "always permitted" so no leftover bits from a prior run survive:

```powershell
Get-ADUser -Filter * -SearchBase "DC=servicedesk,DC=lab" | ForEach-Object {
    Set-ADUser -Identity $_.SamAccountName -Clear logonHours
}
```

---

## Step 3: Review / Edit the Schedule

The schedules live in the `$departments` table inside the script. Each department defines:

- **Weekday core hours** (applied to every enabled user in the OU).
- **An optional weekend exception** — a named list of WFH usernames plus their weekend block.
- **An optional overnight flag** — for shifts that cross midnight (e.g. Saturday evening into Sunday morning), written as two segments.

Edit those values to match the request before running. Hours are entered in **local** time, 24-hour format (start inclusive, end exclusive — e.g. 7–15 = 7:00am to 3:00pm).

---

## Step 4: Run the Script

```powershell
.\16-set-department-logon-hours.ps1 -UtcOffset <your-offset>
```

Output shows each department processed, with a yellow line flagging the weekend shift for each named WFH user, and green "applied" per user. Any failure shows red.

---

## Step 5: Verify

For each schedule type, open a representative user in **ADUC → Properties → Account → Logon Hours…** and read the summary line at the bottom of the grid:

- A **weekday-only** user → confirms the core hours.
- A **weekend WFH** user → confirms core hours **plus** the Saturday block.
- An **overnight** user → the Saturday-evening block sits at the right edge and continues at the left edge of the next day (the wrap is correct, not a bug).

Also spot-check a user who should have **no** weekend shift to confirm the exception logic didn't over-apply.

---

## Step 6: Update the Ticket & Close

Record the departments, the hours applied, the WFH exceptions, and the UTC offset used. Add the UTC display note (below) so the requester isn't alarmed by offset times in the console. Set status to **Resolved**.

---

## Key Technical Notes

- **`Set-ADUser` has no `-LogonHours` parameter.** Write the byte array with `-Replace @{logonHours = $bytes}`.
- **logonHours is a 21-byte array** — 3 bytes per day × 7 days = 168 bits, one per hour of the week. Each set bit = a permitted hour, counted from 00:00 **UTC**. Day order starts at Sunday.
- **The console shows UTC-offset times.** The *enforced* restriction is correct; only the display reflects UTC. State this in the ticket so the requester understands why the grid times may look shifted.
- **Overnight shifts** must be written as two segments and wrapped across the week boundary.
- **Always use error handling** (`-ErrorAction Stop` + try/catch) so a failed user doesn't print a false success.
- **To clear a single user's restriction:**
```powershell
  Set-ADUser -Identity <username> -Clear logonHours
```

---

## Effect on Users

- Logon-hour restrictions are enforced at **authentication time** — a user outside their permitted hours cannot sign in.
- Users **already signed in** when their window ends are **not** forcibly logged off by default (that requires the separate "force logoff when logon hours expire" policy). Note this if the request implies active sessions must end.
- Changes take effect immediately on the domain controller; no client `gpupdate` is needed since this is a user-object attribute, not a GPO.
# Runbook – WSUS Patch Approval & Deployment

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01 (WSUS), Windows clients
**Related Ticket:** [WSUS Patch Compliance](../tickets/ticket-008-WSUS-patch-management.md)
**Scripts:** [26-monitor-wsus-download.ps1](../scripts/26-monitor-wsus-download.ps1)

---

## Purpose

Approve and deploy updates from WSUS to managed clients, targeted by department group, and verify installation. Use for any "patch these machines" request.

---

## ⚠️ Read First: Disk Capacity

WSUS stores every approved update's files on the server's content volume (`C:\WSUS\WsusContent`). **Cumulative updates are large (~3 GB each); approving many at once can fill the disk.** A full content volume crashes the WsusPool application pool and takes the whole WSUS API down — with errors that look unrelated (HTTP 401/503, stalled downloads).

**Before approving in bulk:** check free space and approve conservatively.

```powershell
Get-PSDrive C | Select-Object @{N='Free(GB)';E={[math]::Round($_.Free/1GB,2)}}
```

Rule of thumb for this lab: keep well clear of filling the volume. Approve the **minimum set that satisfies the request** — for a single client, one applicable cumulative, not the whole catalogue.

---

## Step 1: Confirm the Client Is Reporting

A client must appear in the WSUS console before you can target it. In the console: **Computers → All Computers → Unassigned Computers** (new clients land here).

If the client is missing, verify on the client that it's actually using WSUS — not just pointed at it:

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" | Select-Object UseWUServer, AUOptions, NoAutoUpdate
```

`UseWUServer` **must be 1**. If it's missing or 0, the client has the WSUS address but won't use it — fix the GPO (see the [WSUS Setup doc](../docs/09-wsus-setup.md) UseWUServer note) before continuing.

---

## Step 2: Move the Client into a Target Group

WSUS approvals target **groups**, not individual machines. Place the client in its department group (the test ring goes first):

In the console, right-click the computer → **Change Membership** → tick the group (e.g. **IT-PCs**) → OK.

> **Deploy to a test ring first.** Approve to IT-PCs, verify nothing breaks, *then* approve to Sales-PCs / HR-PCs. This is standard patch-ring practice.

---

## Step 3: Identify the Right Update

Only approve updates that **apply to the target's OS and architecture.** Approving mismatched updates (wrong build, wrong CPU architecture, wrong product) wastes disk and download time — they just report "not applicable."

Match the client exactly. Example for a Windows 11 24H2 x64 client: filter the update title for **"Windows 11 Version 24H2 for x64-based Systems"** — not 22H2, not arm64, not "server operating system."

Confirm what the client itself considers applicable (run on the client):

```powershell
$session = New-Object -ComObject Microsoft.Update.Session
$searcher = $session.CreateUpdateSearcher()
$result = $searcher.Search("IsInstalled=0")
$result.Updates | Select-Object Title
```

This lists exactly what WSUS is offering the client — the authoritative "what applies" answer.

---

## Step 4: Approve the Update

In the console: **Updates → Security Updates** (set **Approval: Unapproved**, **Status: Any**, Refresh). Select the update → right-click → **Approve** → click the dropdown next to the target group → **Approved for Install** → OK.

Verify the approval and content state:

```powershell
Get-WsusServer | Get-WsusUpdate -Approval Approved -Status Any | Select-Object @{N='Title';E={$_.Update.Title}}, @{N='State';E={$_.Update.State}}
```

- **State `Ready`** → content is on the server; clients can pull it.
- **State `NotReady`** → server is still downloading content (Step 5).

---

## Step 5: Let the Server Download Content

WSUS downloads the approved update's files from Microsoft before clients can pull them. Monitor headlessly with the loop script (avoids loading the heavy MMC console, which can time out):

```powershell
.\21-monitor-wsus-download.ps1
```

Or inline:

```powershell
while ($true) {
    $p = (Get-WsusServer).GetContentDownloadProgress()
    $pct = [Math]::Round(($p.DownloadedBytes / $p.TotalBytesToDownload) * 100, 2)
    $free = [Math]::Round((Get-PSDrive C).Free / 1GB, 2)
    Write-Host ("{0}% - {1:N0} MB of {2:N0} MB | C: free: {3} GB" -f $pct, ($p.DownloadedBytes/1MB), ($p.TotalBytesToDownload/1MB), $free) -ForegroundColor Cyan
    Start-Sleep -Seconds 30
}
```

**Watch the C: free figure.** If it falls toward 1–2 GB while downloading, stop and free space before it fills (see Recovery). Wait for 100%, then continue.

---

## Step 6: Trigger the Client to Install

On the client, force detection and let it pull + install the approved updates:

```powershell
wuauclt /detectnow
(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
```

Then drive the install through **Settings → Windows Update → Download & install**. The native Windows Update agent (the Settings UI) is more reliable for the actual download/install than scripting the COM downloader, which can trip on transient BITS errors (e.g. `0x80240042`).

Cumulative updates usually require a **reboot** — let the client restart and finish applying (it may sit on "Working on updates" for several minutes; don't interrupt).

---

## Step 7: Verify

On the client, after reboot:

```powershell
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 HotFixID, Description, InstalledOn
```

The deployed KB(s) should appear at the top, dated today. Then report status back to the server:

```powershell
wuauclt /reportnow
```

In the WSUS console (give reporting a few minutes to propagate), the client's status should reflect the installed update.

> **Exclude preview/optional updates.** Non-security "Preview" updates (next month's pre-release) are not part of standard compliance — deploy Critical/Security rollups only.

---

## Step 8: Update the Ticket & Close

Record the update(s) deployed, the target group, the verification (KBs installed), and any disk/cleanup actions. Set status to **Resolved**.

---

## Maintenance: Reclaim Content Space the Right Way

Over time, superseded and expired updates accumulate content on disk. Reclaim it the **supported** way — not by deleting the content folder:

```powershell
Invoke-WsusServerCleanup -CleanupObsoleteComputers -CleanupUnneededContentFiles -DeclineSupersededUpdates -DeclineExpiredUpdates -CompressUpdates
```

Run this periodically (or after large approvals) to keep the content volume healthy.

---

## Recovery: WsusPool Crash / Disk Full

If WSUS API calls return HTTP **401** or **503**, or downloads stall, the WsusPool application pool has likely stopped — often because the content volume filled.

```powershell
# 1. Confirm disk state
Get-PSDrive C | Select-Object Free, Used

# 2. If full, find the consumer
Get-ChildItem "C:\WSUS\WsusContent" -Recurse -File | Measure-Object -Property Length -Sum

# 3. EMERGENCY reclaim (clears downloaded content; WSUS re-downloads only what's approved)
Remove-Item "C:\WSUS\WsusContent\*" -Recurse -Force

# 4. Start the app pool (Start-IISAppPool may be unavailable; appcmd always works)
C:\Windows\System32\inetsrv\appcmd.exe start apppool "WsusPool"

# 5. Confirm the API responds
(Get-WsusServer).GetStatus()
```

**Harden the pool so it doesn't crash under download load:**

```powershell
C:\Windows\System32\inetsrv\appcmd.exe set apppool "WsusPool" /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.privateMemory:0
C:\Windows\System32\inetsrv\appcmd.exe recycle apppool "WsusPool"
```

> Step 3 (manual content deletion) is an **emergency** action. For routine space management, use `Invoke-WsusServerCleanup` above.

---

## Key Notes

- **`Get-WsusServer` only runs on the WSUS server** (AKL-DC01), not on clients.
- **A client only evaluates *approved* updates** — "0 needed" with nothing approved is expected.
- **`UseWUServer = 1` is mandatory** on the client or it ignores WSUS entirely.
- **Match update architecture/build to the client** — mismatched approvals waste space.
- **Settings-UI install > scripted COM download** for reliability.
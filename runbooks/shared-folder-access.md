# Runbook – Shared Folder Access

![Type](https://img.shields.io/badge/Type-Standard%20Procedure-blue)

**Applies To:** `servicedesk.lab` — AKL-DC01
**Related Ticket:** [Shared Folder Access](../tickets/ticket-006-shared-folder-access.md)

---

## Purpose

Diagnose and fix shared-folder access problems. Use this whenever a user reports they can't reach, open, or write to a network share — especially the classic "I can see the folder but get Access Denied" symptom.

---

## Key Concept: Two Permission Layers

A network share has **two** independent permission layers, and a user must pass **both**:

| Layer | Where it lives | Checked with |
|---|---|---|
| **Share** | Network level, on the shared folder | `Get-SmbShareAccess` |
| **NTFS** | File-system level, on the actual files | `Get-Acl` |

**The effective permission is the most restrictive of the two.** Full Control on the share is useless if NTFS denies access. Most "visible but not openable" tickets are *share OK / NTFS blocked*.

> **Reference for this lab:** the Sales share name is `SalesShare`; its folder path is `C:\Shares\Sales`. Share-level commands use the share **name**; NTFS commands use the **path**.

---

## Step 1: Reproduce & Identify

Confirm the symptom with the user — can they see the folder? What exactly happens when they open a file (Access Denied? nothing? read-only)? Note the share and the affected user/group.

---

## Step 2: Check Both Layers

```powershell
# Share layer (use the SHARE NAME)
Get-SmbShareAccess -Name "<ShareName>"

# NTFS layer (use the FOLDER PATH)
(Get-Acl "<FolderPath>").Access |
    Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize
```

Compare the two outputs:

- **Group present in both, with adequate rights** → permissions aren't the cause; look elsewhere (drive mapping GPO, network, the user's group membership).
- **Group present in share but missing/denied in NTFS** → NTFS is blocking. Proceed to fix.
- **Group missing in share** → share-level problem; re-grant at the share (`Grant-SmbShareAccess`).

---

## Step 3: Fix the NTFS Permission

For a missing NTFS permission, restore the group with the appropriate right (Modify is standard for a working department share):

```powershell
$acl = Get-Acl "<FolderPath>"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "SERVICEDESK\<Group>",
    "Modify",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl "<FolderPath>" $acl
```

> `ContainerInherit,ObjectInherit` propagates the permission to all subfolders and files — without it, existing contents stay inaccessible.

If the share layer is the problem instead, grant there:

```powershell
Grant-SmbShareAccess -Name "<ShareName>" -AccountName "SERVICEDESK\<Group>" -AccessRight Change -Force
```

---

## Step 4: Verify

```powershell
(Get-Acl "<FolderPath>").Access |
    Where-Object { $_.IdentityReference -like "*<Group>*" } |
    Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize
```

**Pass criteria:** the group appears with the expected rights (e.g. `Modify`, `Allow`).

---

## Step 5: Confirm with the User & Close

- The user may need to **sign out and back in** (or run `gpupdate /force`) to refresh their group token before access works.
- Confirm they can now open/save files.
- Update the ticket with the root cause (which layer was wrong) and set status to **Resolved**.

---

## Permission Rights Reference

| Right | Use for |
|---|---|
| `Read` / `ReadAndExecute` | View-only access |
| `Modify` | Read, write, edit, delete — standard for working folders |
| `FullControl` | Modify + change permissions — usually admins only, not regular users |

For share-level (`Grant-SmbShareAccess`): `Read`, `Change` (≈ Modify), `Full`.

---

## Notes

- **Always check both layers** before changing anything — fixing the wrong layer wastes time and can over-grant access.
- Share name ≠ folder path — use the right identifier for each command.
- Apply permissions to **groups**, not individual users — fix once, applies to everyone in the group.
- Use inheritance flags so the permission reaches existing files, not just the top folder.
- A user often needs to re-logon for group-based permission changes to take effect.
- GUI: folder → **Properties → Security** (NTFS) and **Sharing → Advanced Sharing → Permissions** (share).
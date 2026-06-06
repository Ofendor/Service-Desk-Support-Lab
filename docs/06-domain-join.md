# Domain Join – WIN11-01

## Purpose
Join the Windows 11 Enterprise client to the `servicedesk.lab` domain so it can authenticate users, receive Group Policy, and access network resources.

## Environment

| Setting | Value |
|---|---|
| Client VM | WIN11-01 |
| Domain Controller | AKL-DC01 (192.168.10.10) |
| Domain | servicedesk.lab |
| Desired Computer OU | Workstations |

---

## Step 1: Verify IP Configuration on WIN11-01

Before joining the domain, the client must use the domain controller as its DNS server. The initial DHCP lease was pointing DNS to the wrong address (192.168.31.1).

**Check current configuration:**
```powershell
ipconfig /all
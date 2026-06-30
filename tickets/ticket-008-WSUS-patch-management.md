# Ticket 008 – WSUS Patch Compliance (Client Registration + Update Deployment)

![Type](https://img.shields.io/badge/Type-Service%20Request-blue)
![Priority](https://img.shields.io/badge/Priority-Normal-green)
![Status](https://img.shields.io/badge/Status-Resolved-success)

**Ticket ID:** #XXXXXX (osTicket)
**Date:** June 2026
**Requester:** IT Management (Priya – IT Support Manager)
**Assigned To:** Hiroshi Tanaka (IT / Service Desk)
**Help Topic:** General Inquiry
**SLA:** Standard – 24h

---

## Scenario

As part of the quarter's security baseline, IT management raised a task with the service desk to bring the managed Windows 11 fleet under WSUS patch control and confirm the pipeline works end to end. The lab had WSUS installed and synchronised on AKL-DC01 (432 security updates staged, three computer groups created), but **no client had ever reported in** — the WSUS console showed zero managed computers.

The task: get WIN11-01 reporting to WSUS, approve and deploy a security update through the proper department-targeted workflow, and verify the patch installed — producing a repeatable patch-approval procedure for the team.

> **Task – Establish WSUS patch compliance (IT Management → Service Desk)**
> *"WSUS is synced but the console shows no computers reporting. Please get WIN11-01 registered, deploy a security update to it through the IT group as a test ring, and confirm it installs. Document the procedure so we can repeat it for the other departments. — Priya, IT Support Manager"*

This ticket turned out to be the most involved in the lab. The "client not reporting" problem masked a genuine configuration defect, and the deployment phase surfaced a real-world disk-capacity incident — both documented below as they happened.

<!-- SCREENSHOT: osTicket task as submitted by IT management -->
![Ticket 008 request](../screenshots/XX-ticket008-osticket-request.png)
*Patch-compliance task as logged for the service desk.*

---

## Why This Matters at an MSP

Patch compliance is one of the core recurring duties of a managed-services desk. This ticket exercises the full lifecycle:

- **WSUS is a local distribution middleman.** Updates download from Microsoft to the server **once**, then clients pull from the server over the LAN — saving bandwidth and giving the admin central control over *what* installs and *when*.
- **Approval is governance.** Clients can only install what's been approved to their group. Approving to **IT-PCs first** (a test ring) before wider rollout mirrors real patch-ring practice.
- **Compliance is provable.** The server reports which machines are patched and which aren't — the difference between "we think we're patched" and "we can show we're patched."
- **Capacity planning is part of the job.** WSUS content can be very large; the system volume must be sized for it. This ticket includes a real disk-full incident and its correct recovery.

---

## Part 1 – Root Cause: Client Not Reporting to WSUS

### Symptom

WSUS was healthy server-side — synced, 432 updates staged, last sync **Succeeded** — but the console reported *"no computers are registered to receive updates"* and **Computers: 0**. WIN11-01 never appeared despite the WSUS client GPO being linked at domain level.

### Diagnosis

The WSUS client GPO (`WSUS Client Configuration`) was confirmed applying to WIN11-01: `gpresult` showed it in the applied list, and the client registry held a correct `WUServer = http://AKL-DC01:8530`. Connectivity was fine (`Test-NetConnection … :8530` → `TcpTestSucceeded: True`) and the Windows Update service was running. Every obvious cause checked out — yet the client still wouldn't report.

The `WindowsUpdate.log` on WIN11-01 exposed the contradiction:
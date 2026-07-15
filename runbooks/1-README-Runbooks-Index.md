# Runbooks – Service Desk Support Lab

This folder contains step-by-step operational procedures ("runbooks") for the recurring tasks a service desk analyst performs. Each runbook is written so someone else could follow it end to end without prior context.

Every runbook below lists the **doc** it builds on (the setup guide), the **script(s)** it uses, and the **ticket** where the procedure was performed in a real scenario.

> Paths are relative to the repository root. Runbook files live in this `runbooks/` folder.

---

## Identity & Account Lifecycle (JML)

### [User Onboarding](user-onboarding.md)
Create a new starter's Active Directory account, place them in the correct OU and security group, and enforce a first-logon password change.
- **Related doc:** [Groups and Users](../docs/05-groups-and-users.md)
- **Related script:** [08-create-users.ps1](../scripts/08-create-users.ps1)
- **Related ticket:** [001 – Onboarding](../tickets/ticket-001-onboarding.md)

### [Offboarding](offboarding.md)
Disable a leaver's account, record and remove group memberships, and move the account to the Disabled Users OU.
- **Related doc:** [Groups and Users](../docs/05-groups-and-users.md)
- **Related ticket:** [005 – Offboarding](../tickets/ticket-005-offoarding-employee.md)

### [Department Transfer](department-transfer.md)
Move a user between departments — update group memberships, relocate the account to the new OU, and set the department attribute.
- **Related doc:** [Organisational Units](../docs/04-organisational-units.md)
- **Related ticket:** [004 – Department Transfer](../tickets/ticket-004-department-transfer.md)

---

## Account Support

### [Password Reset](password-reset.md)
Reset a user's forgotten password and require a change at next logon.
- **Related doc:** [Groups and Users](../docs/05-groups-and-users.md)
- **Related ticket:** [002 – Password Reset](../tickets/ticket-002-password-reset.md)

### [Account Unlock](account-unlock.md)
Unlock an account locked out by the account-lockout policy, and verify the lockout status.
- **Related doc:** [Implementing basic group policies](../docs/07-group-policy.md)
- **Related script:** [12-create-lockout-policy.ps1](../scripts/12-create-lockout-policy.ps1)
- **Related ticket:** [003 – Account Unlock](../tickets/ticket-003-account-unlock.md)

---

## Access & Permissions

### [Shared Folder Access](shared-folder-access.md)
Diagnose and fix shared-folder access issues by distinguishing share-level from NTFS permissions.
- **Related doc:** [Groups and Users](../docs/05-groups-and-users.md)
- **Related scripts:** [13-create-sales-share.ps1](../scripts/13-create-sales-share.ps1), [14-link-sales-drive-gpo.ps1](../scripts/14-link-sales-drive-gpo.ps1)
- **Related ticket:** [006 – Shared Folder Access](../tickets/ticket-006-shared-folder-access.md)

### [Bulk Logon Hours](bulk-logon-hours.md)
Apply logon-hour restrictions across departments via script, including weekend exceptions and the UTC-offset conversion the `logonHours` attribute requires.
- **Related doc:** [Setting Logon hours restrictions for a single user](../docs/08-logon-hours-restrictions.md)
- **Related scripts:** [15-set-logon-hours.ps1](../scripts/15-set-logon-hours.ps1), [16-set-department-logon-hours.ps1](../scripts/16-set-department-logon-hours.ps1)
- **Related ticket:** [007 – Bulk Logon Hours](../tickets/ticket-007-bulk-logon-hours.md)

---

## Patch & Software Management

### [WSUS Patch Approval and Deployment](WSUS-patch-approval-and-deployment.md)
Approve updates in WSUS, target them to a department test-ring group, push them to clients, and verify installation — including disk-capacity and WsusPool recovery.
- **Related doc:** [WSUS Patch Management Setup](../docs/09-wsus-setup.md)
- **Related scripts:** [17-install-wsus.ps1](../scripts/17-install-wsus.ps1), [18-create-wsus-gpo.ps1](../scripts/18-create-wsus-gpo.ps1), [19-wsus-sync-bottleneck-fix.ps1](../scripts/19-wsus-sync-bottleneck-fix.ps1)
- **Related ticket:** [008 – WSUS Patch Management](../tickets/ticket-008-WSUS-patch-management.md)

### [Software Deployment](software-deployment.md)
Deploy third-party software (`.msi`) to domain machines automatically via GPO Software Installation — covering the UNC-path requirement, synchronous policy processing, and the OU-linking gotcha.
- **Related doc:** [Implementing basic group policies](../docs/07-group-policy.md)
- **Related ticket:** [009 – Software Deployment via GPO](../tickets/ticket-009-software-deployment-via-GPO.md)

---

## Runbook Index (quick reference)

| Runbook | Category | Related Ticket |
|---|---|---|
| [user-onboarding.md](user-onboarding.md) | Identity Lifecycle | 001 |
| [password-reset.md](password-reset.md) | Account Support | 002 |
| [account-unlock.md](account-unlock.md) | Account Support | 003 |
| [department-transfer.md](department-transfer.md) | Identity Lifecycle | 004 |
| [offboarding.md](offboarding.md) | Identity Lifecycle | 005 |
| [shared-folder-access.md](shared-folder-access.md) | Access & Permissions | 006 |
| [bulk-logon-hours.md](bulk-logon-hours.md) | Access & Permissions | 007 |
| [WSUS-patch-approval-and-deployment.md](WSUS-patch-approval-and-deployment.md) | Patch Management | 008 |
| [software-deployment.md](software-deployment.md) | Software Management | 009 |
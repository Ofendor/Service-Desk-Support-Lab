# 12-create-lockout-policy.ps1
# Sets the DOMAIN account lockout policy for servicedesk.lab.
# Run on AKL-DC01 as SERVICEDESK\Administrator.
#
# Default LockoutThreshold is 0 = lockout DISABLED — unlimited password
# guesses allowed. This script enables it: 5 bad attempts locks the
# account for 15 minutes, then it self-unlocks.
# LockoutObservationWindow must be <= LockoutDuration.

Write-Host "=== Setting account lockout policy ==="
Set-ADDefaultDomainPasswordPolicy -Identity servicedesk.lab `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 15) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 15)

Write-Host "`n=== Verification ==="
Get-ADDefaultDomainPasswordPolicy |
    Select-Object LockoutThreshold, LockoutDuration, LockoutObservationWindow
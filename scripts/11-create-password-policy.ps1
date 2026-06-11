# Sets the DOMAIN password policy for servicedesk.lab.
# Run on AKL-DC01 as SERVICEDESK\Administrator.
#
# WHY THIS METHOD: Password policy is NOT a registry policy. It lives in
# the Default Domain Policy's Security Settings. Set-GPRegistryValue
# cannot write there — a GPO made that way applies "successfully" and
# enforces nothing. Set-ADDefaultDomainPasswordPolicy edits the real
# policy store, the same place the GPMC GUI writes to.
# NOTE: Only ONE password policy can exist per domain, set at domain level.

Write-Host "=== Setting domain password policy ==="
Set-ADDefaultDomainPasswordPolicy -Identity servicedesk.lab `
    -PasswordHistoryCount 5 `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -MinPasswordAge (New-TimeSpan -Days 1) `
    -MinPasswordLength 8 `
    -ComplexityEnabled $true

Write-Host "`n=== Verification ==="
Get-ADDefaultDomainPasswordPolicy |
    Select-Object ComplexityEnabled, MinPasswordLength, MinPasswordAge,
                  MaxPasswordAge, PasswordHistoryCount
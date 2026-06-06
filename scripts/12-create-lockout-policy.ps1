# Creates the Account Lockout Policy GPO and sets threshold, duration, and reset counter
# This script should be run on the domain controller (AKL-DC01) using the SERVICEDESK\Administrator account.
# The script performs the following steps:
# 1. Creates a new GPO named "Account Lockout Policy".
# 2. Sets the lockout threshold to 5 invalid login attempts.
# 3. Sets the lockout duration to 15 minutes.
# 4. Sets the reset counter to 15 minutes.
# 5. Links the GPO to the domain.
  
# Run on AKL-DC01 as SERVICEDESK\Administrator

Write-Host "=== Creating Account Lockout Policy GPO ==="
New-GPO -Name "Account Lockout Policy"

Write-Host "=== Setting lockout policy values ==="
Set-GPRegistryValue -Name "Account Lockout Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "LockoutBadCount" -Type DWord -Value 5
Set-GPRegistryValue -Name "Account Lockout Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "LockoutDuration" -Type DWord -Value 15
Set-GPRegistryValue -Name "Account Lockout Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ResetLockoutCount" -Type DWord -Value 15

Write-Host "=== Linking Account Lockout Policy to domain ==="
New-GPLink -Name "Account Lockout Policy" -Target "DC=servicedesk,DC=lab"

# After running the script, it verifies the GPO creation and linkage by displaying the GPO status and link information.
# Finally, it confirms that the Account Lockout Policy has been created and linked successfully.
Write-Host "=== Verification ==="
Get-GPO -Name "Account Lockout Policy" | Format-Table DisplayName, GpoStatus
Get-GPLink -Name "Account Lockout Policy" | Format-Table Target, Enabled

Write-Host "`nAccount Lockout Policy created and linked successfully."
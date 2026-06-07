# 15-Set-Logon-Hours.ps1
# Sets logon hours for a single user to Monday-Friday 9:00 AM - 2:00 PM
# Run on AKL-DC01 as SERVICEDESK\Administrator

param(
    [string]$SamAccountName = "tane.williams"
)

Write-Host "=== Setting logon hours for $SamAccountName ==="

$hours = @(
    0x00,0x00, # Sunday     - no access
    0xFC,0xFC, # Monday     - 9am-2pm
    0xFC,0xFC, # Tuesday    - 9am-2pm
    0xFC,0xFC, # Wednesday  - 9am-2pm
    0xFC,0xFC, # Thursday   - 9am-2pm
    0xFC,0xFC, # Friday     - 9am-2pm
    0x00,0x00  # Saturday   - no access
)

Set-ADUser -Identity $SamAccountName -LogonHours $hours

Write-Host "Logon hours set for $SamAccountName"
Write-Host "Allowed: Monday to Friday, 9:00 AM - 2:00 PM"
Write-Host "Denied: All other times, Saturdays, and Sundays"

Write-Host "`n=== Verification ==="
Get-ADUser -Identity $SamAccountName -Properties LogonHours | Select-Object SamAccountName, @{Name="LogonHours";Expression={[System.BitConverter]::ToString($_.LogonHours)}}

# Restricts a single user's logon window: Mon-Fri 9:00 AM - 2:00 PM.
# Run on AKL-DC01 as SERVICEDESK\Administrator Virtual Machine.
#
# HOW IT WORKS: AD stores logon hours as a 21-byte array — 3 bytes per
# day x 7 days, starting Sunday. Each BIT is one hour (bit 0 = midnight).
# Day layout: [byte1: hours 0-7] [byte2: hours 8-15] [byte3: hours 16-23]
# 9am-2pm = hours 9,10,11,12,13 = bits 1-5 of byte2 = 0x3E.
#
# !! TIME ZONE WARNING: AD interprets these bits as UTC. The ADUC GUI
# translates to local time automatically; raw byte writes do NOT.
# In New Zealand (UTC+12/+13) the bits below land 12-13 hours off.
# For exact local-time restrictions, use the GUI (Method 1 in docs/08),
# or shift the bit pattern by your UTC offset according to where you live.

param(
    [string]$SamAccountName = "tane.williams"
)

Write-Host "=== Setting logon hours for $SamAccountName ==="

# Mon-Fri 9:00-14:00 (hours 9-13 inclusive), Sat/Sun denied:
$hours = [byte[]](
    0x00,0x00,0x00,  # Sunday    - no access
    0x00,0x3E,0x00,  # Monday    - 9am-2pm
    0x00,0x3E,0x00,  # Tuesday   - 9am-2pm
    0x00,0x3E,0x00,  # Wednesday - 9am-2pm
    0x00,0x3E,0x00,  # Thursday  - 9am-2pm
    0x00,0x3E,0x00,  # Friday    - 9am-2pm
    0x00,0x00,0x00   # Saturday  - no access
)

# Set-ADUser converts the byte array to the bit pattern AD expects.
Set-ADUser -Identity $SamAccountName -LogonHours $hours 

Write-Host "Logon hours set for $SamAccountName"
Write-Host "Allowed: Monday-Friday, 9:00 AM - 2:00 PM (see UTC note in header)"

Write-Host "`n=== Verification ==="
Get-ADUser -Identity $SamAccountName -Properties LogonHours |
    Select-Object SamAccountName,
        @{Name="LogonHours";Expression={[System.BitConverter]::ToString($_.LogonHours)}}

# CONCLUSION: This method is a bit of a hack, and the UTC quirk makes 
# it unreliable for real-world use. For exact local-time restrictions, 
# use the GUI (Method 1 in docs/08), or shift the bit pattern by your
# UTC offset according to where you live.
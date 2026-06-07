# Sets logon hours for a single user to Monday-Friday 9:00 AM - 2:00 PM, 
# denying access at all other times, including weekends.
# 
# Run on AKL-DC01 as SERVICEDESK\Administrator
# This script uses the Active Directory module, so ensure it is installed and imported before running.
# Parameter for the SamAccountName of the user to modify which means
# the username without the domain part (e.g., "tane.williams" instead of "SERVICEDESK\tane.williams")
param( 
    [string]$SamAccountName = "tane.williams"
)
# 
Write-Host "=== Setting logon hours for $SamAccountName ===" #  Informational message  
# Logon hours are represented as a 21-byte array (168 bits)
# where each bit corresponds to an hour of the week, starting from Sunday 12:00 AM.
$hours = @(
    0x00,0x00, # Sunday     - no access
    0xFC,0xFC, # Monday     - 9am-2pm
    0xFC,0xFC, # Tuesday    - 9am-2pm
    0xFC,0xFC, # Wednesday  - 9am-2pm
    0xFC,0xFC, # Thursday   - 9am-2pm
    0xFC,0xFC, # Friday     - 9am-2pm
    0x00,0x00  # Saturday   - no access
)
# 
Set-ADUser -Identity $SamAccountName -LogonHours $hours # Set the logon hours for the specified user
# 
Write-Host "Logon hours set for $SamAccountName" # Confirmation message
Write-Host "Allowed: Monday to Friday, 9:00 AM - 2:00 PM" # Informational message about allowed logon hours
Write-Host "Denied: All other times, Saturdays, and Sundays" # Informational message about denied logon hours
# 
# Retrieve and display the logon hours for verification,
# showing the SamAccountName and the LogonHours in a readable format.
Write-Host "`n=== Verification ==="
Get-ADUser -Identity $SamAccountName -Properties LogonHours | Select-Object SamAccountName, @{Name="LogonHours";Expression={[System.BitConverter]::ToString($_.LogonHours)}} 

# NOTE: This is an alternative to GUI-based configuration for creating a shared folder and setting permissions.
# Have in mind that these scripts are meant to be run on the domain controller
# (AKL-DC01) using the SERVICEDESK\Administrator account, and they assume that the
# necessary PowerShell modules for Group Policy and SMB sharing are available and imported.
#
#==========================================================
# Creates the Sales shared folder and sets full access for Sales_Group
# Run on AKL-DC01 as SERVICEDESK\Administrator

Write-Host "=== Creating Sales directory ==="
New-Item -Path "C:\Shares\Sales" -ItemType Directory -Force

# Sets permissions for the Sales directory to allow full access for the Sales_Group
Write-Host "=== Creating SMB share ==="
New-SmbShare -Name "SalesShare" -Path "C:\Shares\Sales" -FullAccess "SERVICEDESK\Sales_Group"

# After running the script, it verifies the shared folder
# creation and permissions by displaying the share information.
Write-Host "=== Verification ==="
Get-SmbShare -Name "SalesShare" | Format-Table Name, Path

# Finally, it confirms that the Sales shared folder
# has been created and permissions set successfully.
Write-Host "`nSales shared folder created successfully."
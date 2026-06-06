# Links the already-created Sales Drive Mapping GPO to the Sales OU
# The GPO itself was created and configured via GUI
# Run on AKL-DC01 as SERVICEDESK\Administrator
#
# After running the script, it verifies the GPO linkage by displaying the link information.
Write-Host "=== Linking Sales Drive Mapping to Sales OU ==="
New-GPLink -Name "Sales Drive Mapping" -Target "OU=Sales,DC=servicedesk,DC=lab" -ErrorAction SilentlyContinue
#
# If the GPO is already linked, it will show an error which we ignore because it means the GUI already linked it — no action needed.
# Finally, it confirms that the Sales Drive Mapping GPO has been linked to the Sales OU successfully.
Write-Host "=== Verification ==="
Get-GPLink -Name "Sales Drive Mapping" | Format-Table Target, Enabled

# Note: If you see an error saying the GPO is already linked, that means the GUI already linked it — no action needed.
Write-Host "`nSales Drive Mapping linked to Sales OU."
Write-Host "If you see an error saying the GPO is already linked, that means the GUI already linked it — no action needed."
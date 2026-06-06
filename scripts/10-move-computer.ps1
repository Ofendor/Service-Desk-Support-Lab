# Moves a computer account to the Workstations OU for better organization
# and management within Active Directory.
# Run this on the domain controller (AKL-DC01)
#After running this script, the computer account for WIN11-01 will be
# moved to the specified OU, making it easier to apply group policies
# and manage the computer within the domain. 

$computerName = "WIN11-01"
$targetOU = "OU=Workstations,DC=servicedesk,DC=lab"

Write-Host "Moving $computerName to $targetOU..."
Get-ADComputer -Identity $computerName | Move-ADObject -TargetPath $targetOU

Write-Host "Verifying new location:"
Get-ADComputer -Filter * -SearchBase $targetOU | Format-Table Name, DNSHostName
# Creates Organisational Units for servicedesk.lab
# We need these OUs because we will be adding users and computers to the domain.
# This is a fictional scenario, so the OUs are not based on any real-world requirements.
# Feel free to modify and add as many OUs as you like.

$domainPath = "DC=servicedesk,DC=lab"
$ous = @("Sales", "HR", "IT", "Disabled Users", "Workstations")

Write-Host "=== Creating Organisational Units ==="
# This will create the OUS. Expected result: 5 OUs created: Sales, HR,
# IT, Disabled Users, Workstations. If an OU already exists,
# it will be skipped without error.

foreach ($ou in $ous) {
    New-ADOrganizationalUnit -Name $ou -Path $domainPath -ErrorAction SilentlyContinue
    Write-Host "Created OU: $ou"
}

Write-Host "`n=== Verification ==="
Get-ADOrganizationalUnit -Filter * -SearchBase $domainPath | Where-Object { $_.Name -ne "Domain Controllers" } | Format-Table Name, DistinguishedName

Write-Host "`n=== OU Creation Complete ==="

# NOTE: Disabled Users OU is created to hold user accounts that are disabled, 
# which is a common practice in Active Directory environments.
# The Workstations OU is created to hold computer accounts for workstations,
# which can help with organization and applying Group Policies.
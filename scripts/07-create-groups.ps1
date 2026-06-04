# Creates Security Groups for servicedesk.lab
# Here you will create security groups for each department. 
# These groups can be used later to assign permissions and apply Group Policies. 

$domainPath = "DC=servicedesk,DC=lab"
$groups = @("Sales_Group", "HR_Group", "IT_Group")

Write-Host "=== Creating Security Groups ==="
# Expected result: 3 groups created: Sales_Group, HR_Group, IT_Group.

foreach ($group in $groups) {
    New-ADGroup -Name $group -GroupScope Global -GroupCategory Security -Path $domainPath -ErrorAction SilentlyContinue
    Write-Host "Created group: $group"
}

Write-Host "`n=== Verification ==="
Get-ADGroup -Filter * -SearchBase $domainPath | Where-Object { $_.Name -like "*_Group" } | Format-Table Name, GroupScope, GroupCategory

Write-Host "`n=== Group Creation Complete ==="

# NOTE: The groups created here are Global Security Groups,
# which are commonly used for assigning permissions to users within the same domain.
# Security Groups and Users

## Security Groups

Security groups control access to resources. Users are added to groups based on their department.

| Group | Scope | Type |
|---|---|---|
| Sales_Group | Global | Security |
| HR_Group | Global | Security |
| IT_Group | Global | Security |

### Creation Command

$groups = @("Sales_Group", "HR_Group", "IT_Group")

foreach ($group in $groups) {
    New-ADGroup -Name $group -GroupScope Global -GroupCategory Security -Path "DC=servicedesk,DC=lab"
}

![Groups Created](../screenshots/09-groups-created.png)

## Users

15 users created across three departments. All users must change password at first logon.

### Sales Department (OU: Sales, Group: Sales_Group)

| Name | Username |
|---|---|
| Tane Williams | tane.williams |
| Priya Patel | priya.patel |
| Michael Chen | michael.chen |
| Sarah Thompson | sarah.thompson |
| Amara Okafor | amara.okafor |

### HR Department (OU: HR, Group: HR_Group)

| Name | Username |
|---|---|
| Mei Lin | mei.lin |
| James Kereama | james.kereama |
| Fatima Hassan | fatima.hassan |
| Liam O'Sullivan | liam.osullivan |
| Aroha Henare | aroha.henare |

### IT Department (OU: IT, Group: IT_Group)

| Name | Username |
|---|---|
| Hiroshi Tanaka | hiroshi.tanaka |
| Olivia Brown | olivia.brown |
| Raj Singh | raj.singh |
| Sione Tupou | sione.tupou |
| Maria Gonzalez | maria.gonzalez |

![Users Created](../screenshots/10-users-created.png)

## Scripts
- [Create Groups](../scripts/07-create-groups.ps1)
- [Create Users](../scripts/08-create-users.ps1)

## Next Steps
Proceed to Windows 11 workstation setup and domain join.
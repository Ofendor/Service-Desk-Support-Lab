# Creates 15 users across Sales, HR, and IT departments
# NOTE: Creating 15 users distributed across the three departments was a personal choice.
# You can create as many or as few users as you like, and you can also choose different names and details for the users.

$securePass = ConvertTo-SecureString "CHOOSE A SECURE PASSWORD" -AsPlainText -Force
# The password is showing in plaintext here for simplicity, 
# but in a real-world scenario, you should choose a strong password and keep it secure.
# Make sure to follow your company's password policies when creating user accounts.

$domainPath = "DC=servicedesk,DC=lab"

$users = @(
    @{Name="Tane Williams"; Sam="tane.williams"; Given="Tane"; Surname="Williams"; OU="OU=Sales,$domainPath"; Group="Sales_Group"},
    @{Name="Priya Patel"; Sam="priya.patel"; Given="Priya"; Surname="Patel"; OU="OU=Sales,$domainPath"; Group="Sales_Group"},
    @{Name="Michael Chen"; Sam="michael.chen"; Given="Michael"; Surname="Chen"; OU="OU=Sales,$domainPath"; Group="Sales_Group"},
    @{Name="Sarah Thompson"; Sam="sarah.thompson"; Given="Sarah"; Surname="Thompson"; OU="OU=Sales,$domainPath"; Group="Sales_Group"},
    @{Name="Amara Okafor"; Sam="amara.okafor"; Given="Amara"; Surname="Okafor"; OU="OU=Sales,$domainPath"; Group="Sales_Group"},
    @{Name="Mei Lin"; Sam="mei.lin"; Given="Mei"; Surname="Lin"; OU="OU=HR,$domainPath"; Group="HR_Group"},
    @{Name="James Kereama"; Sam="james.kereama"; Given="James"; Surname="Kereama"; OU="OU=HR,$domainPath"; Group="HR_Group"},
    @{Name="Fatima Hassan"; Sam="fatima.hassan"; Given="Fatima"; Surname="Hassan"; OU="OU=HR,$domainPath"; Group="HR_Group"},
    @{Name="Liam O'Sullivan"; Sam="liam.osullivan"; Given="Liam"; Surname="O'Sullivan"; OU="OU=HR,$domainPath"; Group="HR_Group"},
    @{Name="Aroha Henare"; Sam="aroha.henare"; Given="Aroha"; Surname="Henare"; OU="OU=HR,$domainPath"; Group="HR_Group"},
    @{Name="Hiroshi Tanaka"; Sam="hiroshi.tanaka"; Given="Hiroshi"; Surname="Tanaka"; OU="OU=IT,$domainPath"; Group="IT_Group"},
    @{Name="Olivia Brown"; Sam="olivia.brown"; Given="Olivia"; Surname="Brown"; OU="OU=IT,$domainPath"; Group="IT_Group"},
    @{Name="Raj Singh"; Sam="raj.singh"; Given="Raj"; Surname="Singh"; OU="OU=IT,$domainPath"; Group="IT_Group"},
    @{Name="Sione Tupou"; Sam="sione.tupou"; Given="Sione"; Surname="Tupou"; OU="OU=IT,$domainPath"; Group="IT_Group"},
    @{Name="Maria Gonzalez"; Sam="maria.gonzalez"; Given="Maria"; Surname="Gonzalez"; OU="OU=IT,$domainPath"; Group="IT_Group"}
)

Write-Host "============================================"
Write-Host "  CREATING USERS - SERVICEDESK.LAB"
Write-Host "============================================"

foreach ($user in $users) {
    New-ADUser `
        -Name $user.Name `
        -SamAccountName $user.Sam `
        -UserPrincipalName "$($user.Sam)@servicedesk.lab" `
        -GivenName $user.Given `
        -Surname $user.Surname `
        -DisplayName $user.Name `
        -Path $user.OU `
        -AccountPassword $securePass `
        -ChangePasswordAtLogon $true `
        -Enabled $true
    Add-ADGroupMember -Identity $user.Group -Members $user.Sam
    Write-Host "Created: $($user.Name) -> $($user.Group)"
}

Write-Host "`n=== Verification ==="
# By this, you should see the 15 users created in their respective OUs and groups.

Write-Host "`n--- Sales ---"
Get-ADUser -Filter * -SearchBase "OU=Sales,$domainPath" | Select-Object Name, SamAccountName, Enabled
Write-Host "`n--- HR ---"
Get-ADUser -Filter * -SearchBase "OU=HR,$domainPath" | Select-Object Name, SamAccountName, Enabled
Write-Host "`n--- IT ---"
Get-ADUser -Filter * -SearchBase "OU=IT,$domainPath" | Select-Object Name, SamAccountName, Enabled

Write-Host "`n=== User Creation Complete ==="
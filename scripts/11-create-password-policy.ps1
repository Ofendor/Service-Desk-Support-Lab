# Creates the Password Policy GPO and sets all five password requirements
# (Password History, Maximum Password Age, Minimum Password Age,
# Minimum Password Length, and Password Complexity).
# This script should be run after the baseline GPOs have been created and linked.

# Run on AKL-DC01 as SERVICEDESK\Administrator

Write-Host "=== Creating Password Policy GPO ==="
# The New-GPO cmdlet creates a new Group Policy Object (GPO) with the specified name.
New-GPO -Name "Password Policy"
# The Set-GPRegistryValue cmdlet is used to set specific registry values within the GPO.
# In this case, we are setting the password policy values under the System key in the registry.
# The values being set include:
# - PasswordHistorySize: The number of previous passwords that are remembered and cannot be reused (set to 5).
# - MaximumPasswordAge: The maximum number of days that a password can be used before it must be changed (set to 90).
# - MinimumPasswordAge: The minimum number of days that must pass before a user can change their password again (set to 1).
# - MinimumPasswordLength: The minimum number of characters required for a password (set to 8).
# - PasswordComplexity: A value that determines whether passwords must meet complexity requirements (set to 1, which means complexity is enabled).       
Write-Host "=== Setting password policy values ==="
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordHistorySize" -Type DWord -Value 5
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MaximumPasswordAge" -Type DWord -Value 90
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordAge" -Type DWord -Value 1
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordLength" -Type DWord -Value 8
Set-GPRegistryValue -Name "Password Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordComplexity" -Type DWord -Value 1

Write-Host "=== Linking Password Policy to domain ==="
# The New-GPLink cmdlet is used to link the GPO to a specific target, in this case, the domain "DC=servicedesk,DC=lab".
# This means that the password policy settings defined in the GPO will be applied to all users and computers within that domain.
New-GPLink -Name "Password Policy" -Target "DC=servicedesk,DC=lab"

# Finally, we verify that the GPO was created and linked successfully by retrieving the GPO and its link information.
Write-Host "=== Verification ==="
Get-GPO -Name "Password Policy" | Format-Table DisplayName, GpoStatus
Get-GPLink -Name "Password Policy" | Format-Table Target, Enabled

# If the GPO is created and linked successfully, you should see the GPO listed with
# its status and the link information indicating that it is enabled for the target domain.
Write-Host "`nPassword Policy created and linked successfully."
# Reference script for setting logon hours to multiple users in a department OU.
# Reference script for bulk logon hour assignment 
# Applies predefined profiles to all users in a department OU (Sales, HR, IT) or all OUs at once.
# Run on AKL-DC01 as SERVICEDESK\Administrator 

param(
    [ValidateSet("Sales","HR","IT","All")] # Parameter to specify the department OU to target, or "All" for all departments
    [string]$Department = "All"
)

$baseOU = "DC=servicedesk,DC=lab" # Base distinguished name for the OUs

function Set-UserLogonHours { # Function to set logon hours for all users in a specified OU based on allowed days and hours
    param(
        [string]$OU, # Distinguished name of the OU to target (e.g., "OU=Sales,DC=servicedesk,DC=lab")
        [int[]]$AllowedDays, # Array of integers representing allowed days of the week (0=Sunday, 1=Monday, ..., 6=Saturday)
        [int]$StartHour, # Starting hour for allowed logon time (0-23)
        [int]$EndHour # Ending hour for allowed logon time (0-23, exclusive)
    )
    $users = Get-ADUser -Filter * -SearchBase $OU | Where-Object { $_.Enabled -eq $true } # Get all enabled users in the specified OU
# Initialize a 21-byte array to represent logon hours (168 bits for each hour of the week)
    foreach ($user in $users) {
        $hours = New-Object byte[] 21 

        foreach ($day in $AllowedDays) { 
            $dayByteIndex = $day * 3

            for ($h = $StartHour; $h -lt $EndHour; $h++) { 
                $byteOffset = [math]::Floor($h / 8)
                $bit = $h % 8
                $hours[$dayByteIndex + $byteOffset] = $hours[$dayByteIndex + $byteOffset] -bor (1 -shl $bit) 
            }
        }

        Set-ADUser -Identity $user.SamAccountName -LogonHours $hours # Set the logon hours for the user
        Write-Host "$($user.SamAccountName): profile applied"
    }
# Summary message after processing all users in the OU
    Write-Host "Done. $($users.Count) users updated in $OU." 
}

$depts = if ($Department -eq "All") { @("Sales","HR","IT") } else { @($Department) } # Determine which departments to process based on the input parameter

foreach ($dept in $depts) {
    Write-Host "`n=== Setting logon hours for $dept ===" # Informational message about which department is being processed
    switch ($dept) {
        "Sales" {
            Set-UserLogonHours -OU "OU=Sales,$baseOU" -AllowedDays 1,2,3,4,5 -StartHour 8 -EndHour 18 # Sales: Monday-Friday 8am-6pm
        }
        "HR" {
            Set-UserLogonHours -OU "OU=HR,$baseOU" -AllowedDays 1,2,3,4,5 -StartHour 9 -EndHour 17 # HR: Monday-Friday 9am-5pm
        }
        "IT" {
            Set-UserLogonHours -OU "OU=IT,$baseOU" -AllowedDays 1,2,3,4,5,6 -StartHour 6 -EndHour 22 # IT: Monday-Saturday 6am-10pm
        }
    }
}

Write-Host "`nAll requested profiles applied." 
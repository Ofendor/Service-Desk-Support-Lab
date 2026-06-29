# Reference script for bulk logon hour assignment.
# Applies predefined profiles to all users in a department OU (Sales, HR, IT) or all at once.
# Run on AKL-DC01 as SERVICEDESK\Administrator.
#
# NOTE: logonHours is stored in UTC. The hours written here are literal byte positions,
# so on a UTC+12 (NZ) system the ADUC grid displays them shifted. See the ticket doc.

param(
    [ValidateSet("Sales","HR","IT","All")]
    [string]$Department = "All"
)

$baseOU = "DC=servicedesk,DC=lab"

function Set-UserLogonHours {
    param(
        [string]$OU,
        [int[]]$AllowedDays,   # 0=Sunday ... 6=Saturday
        [int]$StartHour,       # 0-23
        [int]$EndHour          # 0-23, exclusive
    )

    $users = Get-ADUser -Filter * -SearchBase $OU | Where-Object { $_.Enabled -eq $true }

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

        try {
            Set-ADUser -Identity $user.SamAccountName -Replace @{logonHours = $hours} -ErrorAction Stop
            Write-Host "  $($user.SamAccountName): profile applied" -ForegroundColor Green
        }
        catch {
            Write-Host "  $($user.SamAccountName): FAILED - $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "Done. Processed $($users.Count) users in $OU."
}

$depts = if ($Department -eq "All") { @("Sales","HR","IT") } else { @($Department) }

foreach ($dept in $depts) {
    Write-Host "`n=== Setting logon hours for $dept ===" -ForegroundColor Cyan
    switch ($dept) {
        "Sales" { Set-UserLogonHours -OU "OU=Sales,$baseOU" -AllowedDays 1,2,3,4,5   -StartHour 8 -EndHour 18 }  # Mon-Fri 8am-6pm
        "HR"    { Set-UserLogonHours -OU "OU=HR,$baseOU"    -AllowedDays 1,2,3,4,5   -StartHour 9 -EndHour 17 }  # Mon-Fri 9am-5pm
        "IT"    { Set-UserLogonHours -OU "OU=IT,$baseOU"    -AllowedDays 1,2,3,4,5,6 -StartHour 6 -EndHour 22 }  # Mon-Sat 6am-10pm
    }
}

Write-Host "`nAll requested profiles applied."
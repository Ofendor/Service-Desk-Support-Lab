# Bulk logon-hours assignment with per-department schedules and weekend WFH exceptions.
# Run on AKL-DC01 as SERVICEDESK\Administrator.
#
# logonHours is stored in UTC. This script converts the specified LOCAL hours to UTC
# using $UtcOffset so the ADUC grid shows the intended local times.
#   NZ winter (NZST) = +12   |   NZ summer (NZDT) = +13
#   UK = 0 | US Eastern = -5 | Sydney (AEST) = +10
# Anyone reusing this lab from another country: set $UtcOffset to your own UTC offset.

param(
    [int]$UtcOffset = 12   # NZ winter (NZST). Change to match your timezone.
)

$baseOU = "DC=servicedesk,DC=lab"

# --- Helper: add a block of LOCAL hours (for given local days) into a UTC byte array ---
function Add-HoursToMask {
    param(
        [byte[]]$Mask,
        [int[]]$Days,        # 0=Sun ... 6=Sat (LOCAL)
        [int]$StartHour,     # local, inclusive
        [int]$EndHour,       # local, exclusive
        [int]$Offset
    )
    foreach ($day in $Days) {
        for ($h = $StartHour; $h -lt $EndHour; $h++) {
            $localSlot = ($day * 24) + $h
            $utcSlot   = ($localSlot - $Offset) % 168
            if ($utcSlot -lt 0) { $utcSlot += 168 }
            $byteIndex = [math]::Floor($utcSlot / 8)
            $bit       = $utcSlot % 8
            $Mask[$byteIndex] = $Mask[$byteIndex] -bor (1 -shl $bit)
        }
    }
    return $Mask
}

# --- Helper: apply a built mask to one user ---
function Set-UserMask {
    param([string]$Username, [byte[]]$Mask)
    try {
        Set-ADUser -Identity $Username -Replace @{logonHours = $Mask} -ErrorAction Stop
        Write-Host "  $Username : applied" -ForegroundColor Green
    } catch {
        Write-Host "  $Username : FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Department definitions ---
# weekdayStart/End = Mon-Fri local hours. satUsers = WFH exceptions. satDays/Start/End = their Saturday block.
$departments = @(
    @{
        Name = "Sales"; OU = "OU=Sales,$baseOU"
        WeekdayStart = 7; WeekdayEnd = 15                       # 7am-3pm
        SatUsers = @("tane.williams","priya.patel")
        SatDays = @(6); SatStart = 8; SatEnd = 13                # Sat 8am-1pm
    },
    @{
        Name = "HR"; OU = "OU=HR,$baseOU"
        WeekdayStart = 9; WeekdayEnd = 17                        # 9am-5pm
        SatUsers = @("mei.lin","aroha.henare")
        SatDays = @(6); SatStart = 10; SatEnd = 14               # Sat 10am-2pm
    },
    @{
        Name = "IT"; OU = "OU=IT,$baseOU"
        WeekdayStart = 6; WeekdayEnd = 16                        # 6am-4pm
        SatUsers = @("hiroshi.tanaka","raj.singh")
        # Night shift: Sat 17:00 -> Sun 05:00. Split into two blocks.
        # Block A: Saturday 17-24 (i.e. hours 17..23). Block B: Sunday 0-5.
        NightShift = $true
    }
)

foreach ($dept in $departments) {
    Write-Host "`n=== $($dept.Name) (local UTC+$UtcOffset) ===" -ForegroundColor Cyan

    $users = Get-ADUser -Filter * -SearchBase $dept.OU | Where-Object { $_.Enabled }

    foreach ($user in $users) {
        $mask = New-Object byte[] 21

        # Weekday base (Mon-Fri = days 1-5) for everyone
        $mask = Add-HoursToMask -Mask $mask -Days 1,2,3,4,5 `
                    -StartHour $dept.WeekdayStart -EndHour $dept.WeekdayEnd -Offset $UtcOffset

        # Saturday exception for the named WFH users
        if ($dept.SatUsers -contains $user.SamAccountName) {
            if ($dept.NightShift) {
                # Sat 17:00-24:00 (Saturday = day 6, hours 17..23)
                $mask = Add-HoursToMask -Mask $mask -Days 6 -StartHour 17 -EndHour 24 -Offset $UtcOffset
                # Sun 00:00-05:00 (Sunday = day 0, hours 0..4)
                $mask = Add-HoursToMask -Mask $mask -Days 0 -StartHour 0 -EndHour 5 -Offset $UtcOffset
            } else {
                $mask = Add-HoursToMask -Mask $mask -Days $dept.SatDays `
                            -StartHour $dept.SatStart -EndHour $dept.SatEnd -Offset $UtcOffset
            }
            Write-Host "  (Saturday WFH shift added for $($user.SamAccountName))" -ForegroundColor Yellow
        }

        Set-UserMask -Username $user.SamAccountName -Mask $mask
    }
}

Write-Host "`nAll departments processed." -ForegroundColor Cyan
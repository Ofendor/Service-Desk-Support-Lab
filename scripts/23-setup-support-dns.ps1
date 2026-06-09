<#
.SYNOPSIS
    Creates the 'support' DNS A record so osTicket is reachable by name.
.DESCRIPTION
    Adds an A record (support.servicedesk.lab -> 192.168.10.20) to the
    servicedesk.lab forward lookup zone on AKL-DC01, then verifies that
    it resolves. Skips creation cleanly if the record already exists.
.EXAMPLE
    .\23-setup-support-dns.ps1
    Run on AKL-DC01 in an elevated PowerShell session.
#>

# --- Parameters -----------------------------------------------------
$RecordName = "support"
$ZoneName   = "servicedesk.lab"
$TargetIP   = "192.168.10.20"

# --- 1. Create the A record ----------------------------------------
Write-Output "[*] Creating A record: $RecordName.$ZoneName -> $TargetIP"
try {
    Add-DnsServerResourceRecordA -Name $RecordName -ZoneName $ZoneName `
        -IPv4Address $TargetIP -ErrorAction Stop
    Write-Output "[+] Record created successfully."
}
catch {
    if ($_.Exception.Message -like "*already exists*") {
        Write-Output "[!] Record already exists — skipping creation."
    }
    else {
        Write-Output "[X] Failed to create record: $($_.Exception.Message)"
        exit 1
    }
}

# --- 2. Verify the record exists in the zone -----------------------
Write-Output "[*] Confirming record in zone..."
Get-DnsServerResourceRecord -ZoneName $ZoneName -Name $RecordName -RRType A |
    Select-Object HostName, RecordType, @{n='IP';e={$_.RecordData.IPv4Address}}

# --- 3. Verify name resolution -------------------------------------
Write-Output "[*] Testing resolution of $RecordName.$ZoneName..."
try {
    Resolve-DnsName -Name "$RecordName.$ZoneName" -ErrorAction Stop |
        Select-Object Name, IPAddress
    Write-Output "[+] DNS verification complete."
}
catch {
    Write-Output "[X] Resolution failed: $($_.Exception.Message)"
}

Write-Output "--------------------------------------------------------"
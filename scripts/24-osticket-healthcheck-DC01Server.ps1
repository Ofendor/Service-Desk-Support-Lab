# MACHINE: DC01-side only.
<#
.SYNOPSIS
    Health check for the osTicket service from the domain side.
.DESCRIPTION
    Verifies the two things AKL-DC01 is responsible for in the osTicket
    chain: that the friendly name resolves to the reserved address
    (192.168.10.20), and that the service port (8081) answers.
    Read-only — changes nothing. Run when users report the ticketing
    system unreachable, before touching the Debian host.
.EXAMPLE
    .\24-osticket-healthcheck-DC01Server
    Run on AKL-DC01 (or any domain machine with RSAT PowerShell).
#>

$FriendlyName = "support.servicedesk.lab"
$ExpectedIP   = "192.168.10.20"
$Port         = 8081

Write-Output "[*] Checking DNS resolution for $FriendlyName..."
try {
    $dns = Resolve-DnsName $FriendlyName -ErrorAction Stop |
        Where-Object { $_.Type -eq "A" }
    if ($dns.IPAddress -eq $ExpectedIP) {
        Write-Output "[+] DNS OK: resolves to $($dns.IPAddress)"
    }
    else {
        Write-Output "[X] DNS MISMATCH: resolves to $($dns.IPAddress), expected $ExpectedIP"
        Write-Output "    Check the A record and the DHCP reservation on AKL-DC01."
    }
}
catch {
    Write-Output "[X] DNS FAILED: $($_.Exception.Message)"
    Write-Output "    Check the 'support' A record in the servicedesk.lab zone."
}

Write-Output "[*] Testing TCP port $Port on $FriendlyName..."
$tcp = Test-NetConnection $FriendlyName -Port $Port -WarningAction SilentlyContinue
if ($tcp.TcpTestSucceeded) {
    Write-Output "[+] PORT OK: $($tcp.RemoteAddress):$Port is answering"
    Write-Output "[+] Health check PASSED — osTicket reachable at http://${FriendlyName}:$Port"
}
else {
    Write-Output "[X] PORT FAILED: no answer on $Port"
    Write-Output "    Escalate to the Debian host: check 'sudo docker ps' and container logs."
}
Write-Output "--------------------------------------------------------"
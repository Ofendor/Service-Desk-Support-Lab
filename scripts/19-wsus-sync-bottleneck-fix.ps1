<#
.SYNOPSIS
    DATE: JUN 2026
    Remediates frozen initial syncs, database deadlocks, and connection timeouts on WSUS.
.DESCRIPTION
    MAINTENANCE-WINDOW SCRIPT. Temporarily switches the DC's NIC to DHCP for
    the VirtualBox NAT sync workaround, points DNS at public resolvers, resets
    the IIS service layer, and triggers a headless WSUS synchronisation.
    
    !! AD services (domain logons, GPO, domain DNS) are DEGRADED while this
    !! configuration is active. Revert afterwards with:
    !! 20-network-restoration-script.ps1
.EXAMPLE
    .\19-wsus-sync-bottleneck-fix.ps1
    Run elevated on AKL-DC01, AFTER switching the VM's Adapter 1 from
    'NAT Network' to 'NAT' in VirtualBox.
#>

# WARNING — this script deliberately degrades AD. Run only on virtual environments! ;)
Write-Output "[!] WARNING: This switches AKL-DC01 to DHCP and external DNS."
Write-Output "[!] Domain services will be degraded until script 20 restores them."
$confirm = Read-Host "Type YES to continue" 
if ($confirm -ne "YES") {
    Write-Output "[X] Aborted. No changes made."
    exit 0
}

# 1. TEMPORARY MAINTENANCE MODE (NAT sync workaround)
# Switches the NIC to DHCP so the VirtualBox NAT adapter can lease an
# address, and clears the static DNS so the NAT resolver is used.
# NOTE: this is intentional and temporary and NOT a permanent configuration.
# It helped me to troubleshoot and break through the initial WSUS sync bottleneck!
Write-Output "[*] Enabling temporary DHCP mode on the DC NIC..."
Set-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4 -Dhcp Enabled
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses

# Add public forwarders only if they aren't already present
# to ensure the DC can resolve Microsoft update servers.
Write-Output "[*] Ensuring upstream public DNS forwarders exist..."
$existing = (Get-DnsServerForwarder).IPAddress.IPAddressToString
foreach ($fwd in "8.8.8.8", "1.1.1.1") {
    if ($existing -notcontains $fwd) {
        Add-DnsServerForwarder -IPAddress $fwd
        Write-Output "    [+] Added forwarder $fwd"
    } else {
        Write-Output "    [=] Forwarder $fwd already present — skipping"
    }
}
Clear-DnsServerCache -Force # Flush the DNS cache to ensure the new forwarders are used immediately.
ipconfig /flushdns | Out-Null 

# 2. REPAIR AND RESET THE SERVICE LAYER
# Clears frozen IIS worker processes and cycles WSUS to flush bad 
# internal state (deadlocked transactions, hung connections).
# This is a critical step to ensure that the sync engine will be able to
# establish new connections and process updates without getting stuck again.
Write-Output "[*] Cleaning frozen IIS worker processes and web instances..."
Stop-Process -Name w3wp -Force -ErrorAction SilentlyContinue
iisreset /restart 

Write-Output "[*] Cycling core Update Service engine..."
Restart-Service WsusService -Force

# 3. CONFIGURE TARGETED SYNC ENGINE (Headless Framework)
# Headless = no MMC console loaded, which is what kept timing out.
# This forces the sync to run in the background and allows us to monitor
# its progress without the overhead of the GUI, which was a major bottleneck for me at the time.
Write-Output "[*] Initialising target handshake with Microsoft update infrastructure..."
$wsus = Get-WsusServer
$subscription = $wsus.GetSubscription()

# If a (stuck) sync is already running, stop it cleanly before restarting.
# This prevents multiple overlapping sync processes, 
# which can cause further deadlocks and resource contention.
if ($subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
    Write-Output "[!] A synchronisation is already in progress — stopping it first..."
    $subscription.StopSynchronization()
    Start-Sleep -Seconds 10
}

$subscription.StartSynchronization()
Write-Output "[+] Synchronisation triggered."

# 4. MONITOR LIVE PROGRESSION
# Brief pause so the first status read reflects reality, not the
# split-second before the sync engine spins up.
# In simple words: this is just to give you a live readout of the 
# sync progress, which is critical for troubleshooting and ensuring 
# that the bottleneck fix has worked. You should see the phases progressing 
# and items being processed, which is a good sign that the sync is moving forward.
Start-Sleep -Seconds 15
Write-Output "[+] Script complete. Current sync state:"
Write-Output "--------------------------------------------------------"
Write-Output "Status: $($subscription.GetSynchronizationStatus())"
$subscription.GetSynchronizationProgress() |
    Select-Object Phase, TotalItems, ProcessedItems

Write-Output ""
Write-Output "[i] Monitor from another PowerShell terminal with your progress one-liner."
Write-Output "[i] When sync completes: shut down, switch Adapter 1 back to"
Write-Output "    'NAT Network', boot, and run 20-network-restoration-script.ps1."
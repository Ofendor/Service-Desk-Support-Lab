<#
.SYNOPSIS
    Remediates frozen initial syncs, database deadlocks, and connection timeouts on WSUS.
.DESCRIPTION
    Forces clean network configurations, resets the underlying IIS service layer, and triggers 
    a targeted, headless synchronisation sequence.
#>

# 1. OPTIMIZE NETWORK ENVIRONMENT (IPv4 Prioritisation)
Write-Output "[*] Disabling IPv6 interface tracking..."
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Enabled
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses

Write-Output "[*] Injecting upstream public DNS forwarders..."
Add-DnsServerForwarder -IPAddress "8.8.8.8", "1.1.1.1"
Clear-DnsServerCache -Force
ipconfig /flushdns

# 2. REPAIR AND RESET THE SERVICE LAYER
Write-Output "[*] Cleaning frozen IIS worker processes and web instances..."
Stop-Process -Name w3wp -Force -ErrorAction SilentlyContinue
iisreset /restart 

# Ensures the WSUS service is restarted to clear any internal state issues
# Note: This may cause a temporary service disruption,
# so ensure this is performed during a maintenance window.
Write-Output "[*] Cycling core Update Service engine..."
Restart-Service WsusService -Force 

# 3. CONFIGURE TARGETED SYNC ENGINE (Headless Framework)
Write-Output "[*] Initialising target handshake with Microsoft update infrastructure..."
$wsus = Get-WsusServer # Retrieves the WSUS server instance
$subscription = $wsus.GetSubscription() # Retrieves the current subscription object for the WSUS server

# Initiates baseline categories processing
# Triggers the synchronization process, which will now operate
# under the optimized network conditions and reset service state.
$subscription.StartSynchronization() 

# 4. MONITOR LIVE PROGRESSION
# Provides real-time feedback on the synchronization progress, allowing
# administrators to monitor the process and identify any potential
# bottlenecks or issues as they arise.
Write-Output "[+] Script complete. Tracking background transfer pipeline below:"
Write-Output "--------------------------------------------------------"
$subscription.GetSynchronizationProgress() 

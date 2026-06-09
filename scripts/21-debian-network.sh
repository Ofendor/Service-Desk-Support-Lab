# Verify the Debian VM's network state before/after deploying
#           osTicket. Read-only — does NOT modify the existing SCADA
#           host configuration.
# HOST    : Debian VM (192.168.10.20 — pinned via DHCP reservation on DC01)

echo "[*] Current IPv4 on enp0s3 (expecting 192.168.10.20):"
ip a show enp0s3 | grep "inet " # Show only the IPv4 address line for clarity

echo "[*] Default gateway:"
ip route | grep default # Show only the default route line for clarity

echo "[*] Active DNS resolver:"
grep nameserver /etc/resolv.conf # Show only the nameserver lines for clarity

echo "[*] Reachability test — Domain Controller (AKL-DC01):"
ping -c 3 192.168.10.10 # Ping the DC's IP directly to avoid potential name resolution issues

echo "[*] Reachability test — Internet:"
ping -c 3 google.com

echo "[*] Friendly-name resolution (should resolve to 192.168.10.20):"
nslookup support.servicedesk.lab

echo "[+] Network verification complete."
echo "--------------------------------------------------------"


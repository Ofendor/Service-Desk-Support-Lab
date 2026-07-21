#!/usr/bin/env bash
# -------------------------------------------------------------------
# PURPOSE : Health check for the osTicket stack ON the Debian host.
#           Same as scripts/24-osticket-healthcheck.ps1 (DC01 side).
#           Read-only — changes nothing.
# HOST    : Debian VM (192.168.10.20)
# USAGE   : sudo bash 25-osticket-healthcheck.sh
# -------------------------------------------------------------------

PASS=true

# --- 1. CONTAINERS UP? ----------------------------------------------
echo "[*] Checking container status..."
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" \
    --filter "name=osticket"

APP_UP=$(sudo docker ps -q --filter "name=osticket-osticket-1" --filter "status=running")
DB_UP=$(sudo docker ps -q --filter "name=osticket-db-1" --filter "status=running")

if [ -n "$APP_UP" ]; then
    echo "[+] App container (osticket-osticket-1) is running"
else
    echo "[X] App container is NOT running"
    echo "    Try: cd ~/osticket && sudo docker-compose up -d"
    PASS=false
fi

if [ -n "$DB_UP" ]; then
    echo "[+] DB container (osticket-db-1) is running"
else
    echo "[X] DB container is NOT running"
    echo "    Check: sudo docker logs osticket-db-1 --tail 20"
    PASS=false
fi

# --- 2. DATABASE ANSWERING QUERIES? ---------------------------------
# A running DB container is not the same as a healthy database engine.
if [ -n "$DB_UP" ]; then
    echo "[*] Pinging the MariaDB engine inside the DB container..."
    if sudo docker exec osticket-db-1 mariadb-admin ping -u osticket -p<your-osticket-password> --silent 2>/dev/null; then
        echo "[+] Database engine is answering"
    else
        echo "[X] DB container runs but the engine is not responding"
        echo "    Check: sudo docker logs osticket-db-1 --tail 20"
        PASS=false
    fi
fi

# --- 3. APPLICATION SERVING PAGES? ----------------------------------
echo "[*] Testing HTTP response on localhost:8081..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://localhost:8081/scp)
if [ "$HTTP_CODE" = "200" ]; then
    echo "[+] HTTP OK: application responded 200"
elif [ -n "$HTTP_CODE" ] && [ "$HTTP_CODE" != "000" ]; then
    echo "[!] HTTP responded with status $HTTP_CODE (expected 200)"
    echo "    Check: sudo docker logs osticket-osticket-1 --tail 20"
    PASS=false
else
    echo "[X] No HTTP response on port 8081"
    PASS=false
fi

# --- 4. RECENT ERRORS IN THE APP LOG? -------------------------------
echo "[*] Scanning last 50 app log lines for errors..."
ERRORS=$(sudo docker logs osticket-osticket-1 --tail 50 2>&1 | grep -iE "error|fatal" | grep -v "error_log")
if [ -z "$ERRORS" ]; then
    echo "[+] No recent errors in the application log"
else
    echo "[!] Recent log entries worth reviewing:"
    echo "$ERRORS"
fi

# --- VERDICT ---------------------------------------------------------
echo "--------------------------------------------------------"
if [ "$PASS" = true ]; then
    echo "[+] Health check PASSED — osTicket stack is healthy on this host."
    echo "    If users still can't reach it, run scripts/24 on AKL-DC01"
    echo "    to check DNS and port reachability from the domain side."
else
    echo "[X] Health check FAILED — see the [X] items above."
fi
echo "--------------------------------------------------------"
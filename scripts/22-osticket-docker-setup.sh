# Deploy osTicket + MariaDB via Docker Compose, isolated
#           from the host's existing SCADA services.
# HOST    : Debian VM (192.168.10.20 — pinned via DHCP reservation)
# PORT    : 8081 on the host (80 and 8080 already in use here)
# IMAGE   : campbellsoftwaresolutions/osticket
# This script was created to download the osTicket image, 
# set up a MariaDB container, and run both

PROJECT_DIR="$HOME/osticket" # Directory to hold docker-compose.yml and data volumes (adjust as needed)

echo "[*] Creating project directory at $PROJECT_DIR..."
mkdir -p "$PROJECT_DIR" && cd "$PROJECT_DIR" || exit 1 # Exit if directory creation or navigation fails

# Create a docker-compose.yml file with the osTicket and MariaDB service definitions
# OPTIONAL: you can use the content from docker-compose.yml in
# the repo instead of generating it here, but this ensures it's
# created with the correct content and permissions
echo "[*] Writing docker-compose.yml..."
cat > docker-compose.yml << 'EOF' 
version: '3'

services:
  db:
    image: mariadb:10.6
    environment:
      MYSQL_ROOT_PASSWORD: OsticketRoot123!
      MYSQL_DATABASE: osticket
      MYSQL_USER: osticket
      MYSQL_PASSWORD: OsticketPass123!
    volumes:
      - db_data:/var/lib/mysql
    restart: always

  osticket:
    image: campbellsoftwaresolutions/osticket
    environment:
      MYSQL_HOST: db
      MYSQL_DATABASE: osticket
      MYSQL_USER: osticket
      MYSQL_PASSWORD: OsticketPass123!
    ports:
      - "8081:80"
    volumes:
      - osticket_data:/var/www/html
    restart: always
    depends_on:
      - db

volumes:
  db_data:
  osticket_data:
EOF

echo "[*] Allowing port 8081 through the firewall (skip if ufw inactive)..."
sudo ufw allow 8081/tcp 2>/dev/null || echo "    ufw not active — Docker publishes the port regardless."

echo "[*] Starting containers..."
sudo docker-compose up -d

echo "[*] Waiting 30s for containers to initialise..."
sleep 30

echo "[*] Verifying container status (expect two 'Up' containers):"
sudo docker ps

echo "[+] osTicket deployment complete."
echo "    Access via friendly name : http://support.servicedesk.lab:8081"
echo "    Direct (on Debian)        : http://192.168.10.20:8081"
echo "    Staff panel               : http://support.servicedesk.lab:8081/scp"
echo "--------------------------------------------------------"
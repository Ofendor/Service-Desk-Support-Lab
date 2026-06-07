#======PATCH MANAGEMENT TOOL============
# WSUS stands for Windows Server Update Services, which is a role in Windows Server that 
# allows administrators to manage and distribute updates for Microsoft products within
# their network. WSUS enables IT administrators to control the deployment of updates,
# ensuring that systems are kept up-to-date with the latest security patches and
# features while minimizing bandwidth usage and providing reporting capabilities.
#=====================================================================
# Installs WSUS role, creates content directory, and runs post-install
# Run on PowerShell as an administrator
# Run on AKL-DC01 Virtual Machine as SERVICEDESK\Administrator

Write-Host "=== Installing WSUS Role ==="
Install-WindowsFeature UpdateServices -IncludeManagementTools 

Write-Host "=== Creating WSUS content directory ==="
New-Item -Path "C:\WSUS" -ItemType Directory -Force 

Write-Host "=== Running WSUS Post-Install ==="
cd "C:\Program Files\Update Services\Tools"
.\wsusutil.exe postinstall CONTENT_DIR=C:\WSUS

Write-Host "`n=== WSUS installed. Open WSUS Console and run first sync. ==="
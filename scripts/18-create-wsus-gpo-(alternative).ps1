# 18-create-wsus-gpo-_alternative_.ps1
# Same as 18-create-wsus-gpo.ps1, formatted with line continuations
# for readability. Comments must sit ABOVE commands — a backtick only
# continues a line when it is the LAST character on that line.

Write-Host "=== Creating WSUS Client Configuration GPO ==="
New-GPO -Name "WSUS Client Configuration" -ErrorAction SilentlyContinue

# WUServer: the WSUS server clients download updates from.
Set-GPRegistryValue -Name "WSUS Client Configuration" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" `
    -ValueName "WUServer" `
    -Type String `
    -Value "http://AKL-DC01:8530"

# WUStatusServer: where clients report their update status.
Set-GPRegistryValue -Name "WSUS Client Configuration" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" `
    -ValueName "WUStatusServer" `
    -Type String `
    -Value "http://AKL-DC01:8530"

# NoAutoUpdate = 0 means automatic updates are ENABLED.
Set-GPRegistryValue -Name "WSUS Client Configuration" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -ValueName "NoAutoUpdate" `
    -Type DWord `
    -Value 0

# AUOptions = 3: auto-download updates, notify user before install.
Set-GPRegistryValue -Name "WSUS Client Configuration" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -ValueName "AUOptions" `
    -Type DWord `
    -Value 3

Write-Host "=== Linking GPO to domain ==="
New-GPLink -Name "WSUS Client Configuration" -Target "DC=servicedesk,DC=lab" -ErrorAction SilentlyContinue

Write-Host "`n=== Verification ==="
Get-GPInheritance -Target "DC=servicedesk,DC=lab" |
    Select-Object -ExpandProperty GpoLinks
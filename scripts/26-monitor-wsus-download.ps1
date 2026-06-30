<#
.SYNOPSIS
    Monitors WSUS update content download progress from the command line. Run this script in DC01 Server VM.

.DESCRIPTION
    When updates are approved in WSUS, the server downloads their content files
    from Microsoft before clients can pull them. The WSUS MMC console is heavy and
    can time out during large downloads, so this script polls download progress
    headlessly via the WSUS API instead.

    It reports overall percentage, MB downloaded vs. total, and — importantly —
    current free space on the content volume (C:). Cumulative updates are large,
    and over-approving can fill the disk, which crashes the WsusPool application
    pool. Watching the free-space figure lets you stop before the disk fills.

    Run on the WSUS server (AKL-DC01). Press Ctrl+C to stop.

.PARAMETER DriveLetter
    The volume hosting the WSUS content store, checked for free space. Default 'C'.

.EXAMPLE
    .\26-monitor-wsus-download.ps1
    Polls every 30 seconds, showing download progress and C: free space.

.EXAMPLE
    .\26-monitor-wsus-download.ps1 -IntervalSeconds 15 -DriveLetter C
    Polls every 15 seconds against the C: volume.

.NOTES
    Must run on the WSUS server — Get-WsusServer is not available on clients.
    If progress stalls and free space is near zero, stop and reclaim space
    (see the WSUS Patch Approval runbook, Recovery section).
#>

[CmdletBinding()]
param(
    [int]$IntervalSeconds = 30,
    [string]$DriveLetter = "C"
)

try {
    $wsus = Get-WsusServer -ErrorAction Stop
} catch {
    Write-Host "ERROR: Could not connect to WSUS. Run this on the WSUS server (AKL-DC01)." -ForegroundColor Red
    Write-Host "Detail: $($_.Exception.Message)" -ForegroundColor Red
    return
}

Write-Host "Monitoring WSUS content download (Ctrl+C to stop)..." -ForegroundColor Cyan
Write-Host ""

while ($true) {
    try {
        $p = $wsus.GetContentDownloadProgress()

        if ($p.TotalBytesToDownload -gt 0) {
            $pct = [Math]::Round(($p.DownloadedBytes / $p.TotalBytesToDownload) * 100, 2)
        } else {
            $pct = 100   # nothing queued = nothing to download
        }

        $free = [Math]::Round((Get-PSDrive $DriveLetter).Free / 1GB, 2)

        # Colour the free-space warning: red under 3 GB, yellow under 8 GB, else cyan
        $colour = if ($free -lt 3) { "Red" } elseif ($free -lt 8) { "Yellow" } else { "Cyan" }

        Write-Host ("{0}% - {1:N0} MB of {2:N0} MB | {3}: free: {4} GB" -f `
            $pct, ($p.DownloadedBytes / 1MB), ($p.TotalBytesToDownload / 1MB), $DriveLetter, $free) `
            -ForegroundColor $colour

        if ($pct -ge 100 -and $p.TotalBytesToDownload -gt 0) {
            Write-Host "`nDownload complete — all approved content is on the server." -ForegroundColor Green
            break
        }
    }
    catch {
        # A 401/503 here usually means WsusPool crashed (often a full disk).
        Write-Host "WSUS API call failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "If this persists, check disk space and WsusPool (see runbook Recovery)." -ForegroundColor Yellow
    }

    Start-Sleep -Seconds $IntervalSeconds
}
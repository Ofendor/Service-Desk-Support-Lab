<#
.SYNOPSIS
    Monitors WSUS update content download progress from the command line.

.DESCRIPTION
    When updates are approved in WSUS, the server downloads their content files
    from Microsoft before clients can pull them. The WSUS MMC console is heavy and
    can time out during large downloads, so this script polls download progress
    headlessly via the WSUS API instead.

    It reports a timestamp, overall percentage, MB downloaded vs. total, and —
    importantly — current free space on the content volume (C:). Cumulative updates
    are large, and over-approving can fill the disk, which crashes the WsusPool
    application pool. The script aborts automatically if free space falls below a
    safety threshold, so the disk never fills mid-download.

    Run on the WSUS server (AKL-DC01). Press Ctrl+C to stop.

.PARAMETER IntervalSeconds
    Seconds between progress checks. Default 30.

.PARAMETER DriveLetter
    The volume hosting the WSUS content store, checked for free space. Default 'C'.

.PARAMETER AbortFreeGB
    If free space on the content volume falls below this many GB, the script stops
    and warns — protecting against a full-disk WsusPool crash. Default 2.

.EXAMPLE
    .\21-monitor-wsus-download.ps1
    Polls every 30 seconds; aborts if C: free space drops below 2 GB.

.EXAMPLE
    .\21-monitor-wsus-download.ps1 -IntervalSeconds 15 -AbortFreeGB 5
    Polls every 15 seconds; aborts if free space drops below 5 GB.

.NOTES
    Must run on the WSUS server — Get-WsusServer is not available on clients.
    If progress stalls and free space is near zero, reclaim space
    (see the WSUS Patch Approval runbook, Recovery section).
#>

[CmdletBinding()]
param(
    [int]$IntervalSeconds = 30,
    [string]$DriveLetter  = "C",
    [int]$AbortFreeGB     = 2
)

try {
    $wsus = Get-WsusServer -ErrorAction Stop
} catch {
    Write-Host "ERROR: Could not connect to WSUS. Run this on the WSUS server (AKL-DC01)." -ForegroundColor Red
    Write-Host "Detail: $($_.Exception.Message)" -ForegroundColor Red
    return
}

Write-Host "Monitoring WSUS content download (Ctrl+C to stop)..." -ForegroundColor Cyan
Write-Host "Will auto-abort if $($DriveLetter): free space drops below $AbortFreeGB GB." -ForegroundColor Cyan
Write-Host ""

while ($true) {
    try {
        $p  = $wsus.GetContentDownloadProgress()
        $ts = Get-Date -Format 'HH:mm:ss'

        if ($p.TotalBytesToDownload -gt 0) {
            # Clamp at 100 — if more updates are approved mid-session the total
            # can shift and the raw percentage can briefly exceed 100.
            $pct = [Math]::Min([Math]::Round(($p.DownloadedBytes / $p.TotalBytesToDownload) * 100, 2), 100)
        } else {
            $pct = 100   # nothing queued = nothing to download
        }

        $free = [Math]::Round((Get-PSDrive $DriveLetter).Free / 1GB, 2)

        # Colour the free-space warning: red under 3 GB, yellow under 8 GB, else cyan
        $colour = if ($free -lt 3) { "Red" } elseif ($free -lt 8) { "Yellow" } else { "Cyan" }

        Write-Host ("[{0}] {1}% - {2:N0} MB of {3:N0} MB | {4}: free: {5} GB" -f `
            $ts, $pct, ($p.DownloadedBytes / 1MB), ($p.TotalBytesToDownload / 1MB), $DriveLetter, $free) `
            -ForegroundColor $colour

        # Proactive safety: stop before the disk fills and crashes WsusPool.
        if ($free -lt $AbortFreeGB) {
            Write-Host "`nABORTING: $($DriveLetter): free space ($free GB) below threshold ($AbortFreeGB GB)." -ForegroundColor Red
            Write-Host "Decline unneeded updates and run Invoke-WsusServerCleanup to reclaim space (see runbook Recovery)." -ForegroundColor Yellow
            break
        }

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
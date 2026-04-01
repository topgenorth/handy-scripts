# PowerShell script: Enable case sensitivity recursively
# Run as Administrator in parent directory
# Usage: .\EnableCaseSensitive.ps1 -Path "C:\Temp\some-directory" [-Backup]

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [switch]$Backup
)

$fullPath = Resolve-Path $Path
Write-Host "Target: $fullPath" -ForegroundColor Green

if ($Backup) {
    $backupPath = "$fullPath.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $fullPath $backupPath -Recurse -Force
    Write-Host "Backup created: $backupPath" -ForegroundColor Yellow
}

# Enable on ALL subdirectories recursively (works on non-empty)
$subDirs = Get-ChildItem $fullPath -Recurse -Directory -ErrorAction SilentlyContinue
foreach ($dir in $subDirs) {
    try {
        fsutil.exe file SetCaseSensitiveInfo $dir.FullName enable | Out-Null
        Write-Host "Enabled: $($dir.FullName)" -ForegroundColor Green
    } catch {
        Write-Warning "Failed: $($dir.FullName) - $_"
    }
}

# Attempt root (may fail if non-empty)
try {
    fsutil.exe file SetCaseSensitiveInfo $fullPath enable | Out-Null
    Write-Host "Root enabled: $fullPath" -ForegroundColor Green
} catch {
    Write-Warning "Root failed (normal for non-empty): $_"
}

Write-Host "`nVerify: fsutil.exe file QueryCaseSensitiveInfo $fullPath" -ForegroundColor Cyan

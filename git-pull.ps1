$repos = @(
    "~/Dir1",
    "~/Dir2"
)

foreach ($dir in $repos) {
    $name = Split-Path $dir -Leaf
    Write-Host "=== $name ==="

    if (-not (Test-Path (Join-Path $dir ".git"))) {
        Write-Host "Not a git repository: $dir"
        Write-Host ""
        continue
    }

    $status = git -C $dir status --porcelain

    if ([string]::IsNullOrWhiteSpace(($status | Out-String))) {
        Write-Host "No local changes detected, skipping git pull"
    }
    else {
        Write-Host "Changes detected, running git pull"
        git -C $dir pull
    }

    Write-Host ""
}
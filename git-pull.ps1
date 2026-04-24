#!/usr/bin/env pwsh

$repos = @(
    "Dir1",
    "Dir2"
)

foreach ($dir in $repos) {
    $name = Split-Path $dir -Leaf
    Write-Host "=== $name ==="

    if (Test-Path (Join-Path $dir ".git")) {
        git -C $dir pull
    }
    else {
        Write-Host "Not a git repository: $dir"
    }

    Write-Host ""
}
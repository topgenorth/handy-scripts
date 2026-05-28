#!/usr/bin/env pwsh

param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FitFileDirectory
)

$ErrorActionPreference = 'Stop'

# Linux path: /media/tom/GARMIN/Garmin/Shot_Sessions
if (-not (Test-Path -LiteralPath $FitFileDirectory -PathType Container)) {
    Write-Error "FIT file directory not found or is not a directory: $FitFileDirectory"
    exit 1
}

$fitFiles = Get-ChildItem -LiteralPath $FitFileDirectory -File -Filter '*.fit'

if (-not $fitFiles) {
    Write-Host "No .fit files found in: $FitFileDirectory"
    exit 0
}

foreach ($fitFile in $fitFiles) {
    $fitFileName = $fitFile.FullName
    Write-Host "Adding range asset: $fitFileName"

    $args = @(
        'range-assets'
        'add'
        '--file'
        $fitFileName
    )

    & mlrb @args

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to add range asset: $fitFileName (exit code: $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
}
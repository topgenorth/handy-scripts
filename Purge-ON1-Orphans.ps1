param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw "Directory not found: $Path"
}

# Add or remove image extensions here as needed
$imageExtensions = @(
    '.jpg', '.jpeg', '.tif', '.tiff', '.png', '.psd',
    '.dng', '.heic', '.heif',
    '.cr2', '.cr3', '.nef', '.nrw', '.arw', '.srf', '.sr2',
    '.orf', '.rw2', '.raf', '.pef', '.raw'
)

$imageExtSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($ext in $imageExtensions) {
    [void]$imageExtSet.Add($ext)
}

$deleted = 0
$kept = 0

Get-ChildItem -LiteralPath $Path -Recurse -File -Filter '*.on1' | ForEach-Object {
    $on1File = $_

    # For ON1 sidecars like photo.nef.on1, this gives "photo.nef"
    $baseWithoutOn1 = [System.IO.Path]::GetFileNameWithoutExtension($on1File.Name)

    # For the image candidate, split into basename + image extension
    $imageBaseName = [System.IO.Path]::GetFileNameWithoutExtension($baseWithoutOn1)
    $imageExtension = [System.IO.Path]::GetExtension($baseWithoutOn1)

    $hasMatchingImage =
        ($imageExtension -and $imageExtSet.Contains($imageExtension)) -and
        (Test-Path -LiteralPath (Join-Path $on1File.DirectoryName $baseWithoutOn1) -PathType Leaf)

    if (-not $hasMatchingImage) {
        if ($WhatIf) {
            Write-Host "[WhatIf] Would delete orphan: $($on1File.FullName)"
        }
        else {
            Remove-Item -LiteralPath $on1File.FullName -Force
            Write-Host "Deleted orphan: $($on1File.FullName)"
        }
        $deleted++
    }
    else {
        $kept++
    }
}

Write-Host ""
Write-Host "Done. Kept: $kept  Deleted: $deleted"
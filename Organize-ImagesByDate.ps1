param(
    [Parameter(Mandatory=$true)]
    [string]$Directory
)

# Validate directory exists
if (-not (Test-Path -Path $Directory -PathType Container)) {
    Write-Error "Directory does not exist: $Directory"
    exit 1
}

# Add System.Drawing assembly for image metadata reading
Add-Type -AssemblyName System.Drawing

function Get-ImageDateTaken {
    param([string]$FilePath)
    
    try {
        $image = [System.Drawing.Image]::FromFile($FilePath)
        
        # Try to get EXIF PropertyItem for Date Taken
        # Property ID 36867 = DateTimeOriginal (EXIF)
        # Property ID 306 = DateTime (EXIF)
        # Property ID 36868 = DateTimeDigitized (EXIF)
        
        $dateTaken = $null
        
        # Try DateTimeOriginal first (most common for photos)
        try {
            $propertyItem = $image.GetPropertyItem(36867)
            if ($propertyItem -ne $null) {
                $dateString = [System.Text.Encoding]::ASCII.GetString($propertyItem.Value)
                $dateString = $dateString.TrimEnd([char]0)
                # EXIF date format is typically "yyyy:MM:dd HH:mm:ss"
                if ($dateString -match '^(\d{4}):(\d{2}):(\d{2})') {
                    $dateTaken = [DateTime]::ParseExact($dateString, "yyyy:MM:dd HH:mm:ss", $null)
                }
            }
        } catch {
            # Property not found, continue
        }
        
        # If DateTimeOriginal not found, try DateTime
        if ($dateTaken -eq $null) {
            try {
                $propertyItem = $image.GetPropertyItem(306)
                if ($propertyItem -ne $null) {
                    $dateString = [System.Text.Encoding]::ASCII.GetString($propertyItem.Value)
                    $dateString = $dateString.TrimEnd([char]0)
                    if ($dateString -match '^(\d{4}):(\d{2}):(\d{2})') {
                        $dateTaken = [DateTime]::ParseExact($dateString, "yyyy:MM:dd HH:mm:ss", $null)
                    }
                }
            } catch {
                # Property not found, continue
            }
        }
        
        # If still not found, try DateTimeDigitized
        if ($dateTaken -eq $null) {
            try {
                $propertyItem = $image.GetPropertyItem(36868)
                if ($propertyItem -ne $null) {
                    $dateString = [System.Text.Encoding]::ASCII.GetString($propertyItem.Value)
                    $dateString = $dateString.TrimEnd([char]0)
                    if ($dateString -match '^(\d{4}):(\d{2}):(\d{2})') {
                        $dateTaken = [DateTime]::ParseExact($dateString, "yyyy:MM:dd HH:mm:ss", $null)
                    }
                }
            } catch {
                # Property not found, continue
            }
        }
        
        $image.Dispose()
        return $dateTaken
    }
    catch {
        Write-Warning "Error reading image metadata from $FilePath : $_"
        return $null
    }
}

# Get all files in the directory (excluding subdirectories)
$files = Get-ChildItem -Path $Directory -File

$processedCount = 0
$skippedCount = 0
$deletedCount = 0
$errorCount = 0

Write-Host "Processing $($files.Count) files in $Directory..." -ForegroundColor Cyan

foreach ($file in $files) {
    try {
        # Check if file is 0 bytes and delete it
        if ($file.Length -eq 0) {
            Remove-Item -Path $file.FullName -Force
            Write-Host "Deleted 0-byte file: $($file.Name)" -ForegroundColor Magenta
            $deletedCount++
            continue
        }
        
        # Skip .TIF files
        if ($file.Extension -ieq '.TIF') {
            Write-Host "Skipping $($file.Name) - .TIF files are ignored" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        # Get date from image metadata
        $dateTaken = Get-ImageDateTaken -FilePath $file.FullName
        
        if ($dateTaken -eq $null) {
            Write-Host "Skipping $($file.Name) - no date metadata found" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        # Format date as yyyy-MM
        $dateFolder = $dateTaken.ToString("yyyy-MM")
        $targetFolder = Join-Path -Path $Directory -ChildPath $dateFolder
        
        # Create folder if it doesn't exist
        if (-not (Test-Path -Path $targetFolder)) {
            New-Item -Path $targetFolder -ItemType Directory | Out-Null
            Write-Host "Created folder: $dateFolder" -ForegroundColor Green
        }
        
        # Move file to target folder
        $targetPath = Join-Path -Path $targetFolder -ChildPath $file.Name
        
        # Handle potential name conflicts
        if (Test-Path -Path $targetPath) {
            $counter = 1
            $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $extension = [System.IO.Path]::GetExtension($file.Name)
            
            while (Test-Path -Path $targetPath) {
                $newName = "$nameWithoutExt-$counter$extension"
                $targetPath = Join-Path -Path $targetFolder -ChildPath $newName
                $counter++
            }
            Write-Host "File already exists, renaming to: $([System.IO.Path]::GetFileName($targetPath))" -ForegroundColor Yellow
        }
        
        Move-Item -Path $file.FullName -Destination $targetPath -Force
        Write-Host "Moved $($file.Name) -> $dateFolder\$([System.IO.Path]::GetFileName($targetPath))" -ForegroundColor Green
        $processedCount++
    }
    catch {
        Write-Error "Error processing $($file.Name): $_"
        $errorCount++
    }
}

Write-Host "`nProcessing complete!" -ForegroundColor Cyan
Write-Host "  Processed: $processedCount" -ForegroundColor Green
Write-Host "  Skipped (no metadata): $skippedCount" -ForegroundColor Yellow
Write-Host "  Deleted (0 bytes): $deletedCount" -ForegroundColor Magenta
Write-Host "  Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })


param(
    [Parameter(Mandatory=$true)]
    [string]$Directory
)

# Check if the directory exists
if (-not (Test-Path -Path $Directory -PathType Container)) {
    Write-Error "Directory '$Directory' does not exist."
    exit 1
}

# Convert to absolute path
$TargetDirectory = Resolve-Path -Path $Directory

Write-Host "Moving all files from subdirectories to: $TargetDirectory" -ForegroundColor Green

# Function to generate a unique filename
function Get-UniqueFileName {
    param(
        [string]$Directory,
        [string]$FileName
    )
    
    $BasePath = Join-Path -Path $Directory -ChildPath $FileName
    
    # If file doesn't exist, return the original name
    if (-not (Test-Path -Path $BasePath)) {
        return $FileName
    }
    
    # Extract name and extension
    $NameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $Extension = [System.IO.Path]::GetExtension($FileName)
    
    # Try appending numbers until we find a unique name
    $Counter = 1
    $NewFileName = "$NameWithoutExtension($Counter)$Extension"
    $NewPath = Join-Path -Path $Directory -ChildPath $NewFileName
    
    while (Test-Path -Path $NewPath) {
        $Counter++
        $NewFileName = "$NameWithoutExtension($Counter)$Extension"
        $NewPath = Join-Path -Path $Directory -ChildPath $NewFileName
    }
    
    return $NewFileName
}

# Get all subdirectories (recursively)
$Subdirectories = Get-ChildItem -Path $TargetDirectory -Directory -Recurse

$FileCount = 0
$ErrorCount = 0
$RenamedCount = 0

foreach ($SubDir in $Subdirectories) {
    # Get all files in the current subdirectory (non-recursive, just files in this specific directory)
    $Files = Get-ChildItem -Path $SubDir.FullName -File
    
    foreach ($File in $Files) {
        try {
            $OriginalDestinationPath = Join-Path -Path $TargetDirectory -ChildPath $File.Name
            
            # Check if file already exists in target directory
            if (Test-Path -Path $OriginalDestinationPath) {
                # Generate a unique filename
                $UniqueFileName = Get-UniqueFileName -Directory $TargetDirectory -FileName $File.Name
                $DestinationPath = Join-Path -Path $TargetDirectory -ChildPath $UniqueFileName
                Write-Host "Renaming '$($File.Name)' to '$UniqueFileName' due to naming conflict" -ForegroundColor Yellow
                $RenamedCount++
            }
            else {
                $DestinationPath = $OriginalDestinationPath
            }
            
            # Move the file
            Move-Item -Path $File.FullName -Destination $DestinationPath -Force
            Write-Host "Moved: $([System.IO.Path]::GetFileName($DestinationPath))" -ForegroundColor Cyan
            $FileCount++
        }
        catch {
            Write-Error "Failed to move '$($File.Name)': $_"
            $ErrorCount++
        }
    }
}

Write-Host "`nCompleted!" -ForegroundColor Green
Write-Host "Files moved: $FileCount" -ForegroundColor Green
if ($RenamedCount -gt 0) {
    Write-Host "Files renamed due to conflicts: $RenamedCount" -ForegroundColor Yellow
}
if ($ErrorCount -gt 0) {
    Write-Host "Errors: $ErrorCount" -ForegroundColor Red
}


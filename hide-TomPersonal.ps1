# Define registry path for OneDrive in navigation pane
$regPath = "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$name = "System.IsPinnedToNameSpaceTree"

# Create key if it doesn't exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set DWORD value to 0 (unpins it)
New-ItemProperty -Path $regPath -Name $name -Value 0 -PropertyType DWORD -Force

Write-Output "OneDrive unpinned. Restart File Explorer: Task Manager > Restart explorer.exe"

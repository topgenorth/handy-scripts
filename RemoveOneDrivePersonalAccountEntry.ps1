# # Define registry path for OneDrive in navigation pane
# $regPath = "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
# $name = "System.IsPinnedToNameSpaceTree"

# # Create key if it doesn't exist
# if (-not (Test-Path $regPath)) {
#     New-Item -Path $regPath -Force | Out-Null
# }

# # Set DWORD value to 0 (unpins it)
# New-ItemProperty -Path $regPath -Name $name -Value 0 -PropertyType DWORD -Force

# Write-Output "OneDrive unpinned. Restart File Explorer: Task Manager > Restart explorer.exe"


## Remove OneDrive personal account entry in File Explorer.
# System-wide removal (HKCR/HKLM paths)
$clsidPath = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$desktopPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$nonEnumPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum"

# Set CLSID pin to 0
if (-not (Test-Path $clsidPath)) { New-Item -Path $clsidPath -Force | Out-Null }
New-ItemProperty -Path $clsidPath -Name "System.IsPinnedToNameSpaceTree" -Value 0 -PropertyType DWORD -Force

# Set Desktop Namespace hidden
if (-not (Test-Path $desktopPath)) { New-Item -Path $desktopPath -Force | Out-Null }
New-ItemProperty -Path $desktopPath -Name "HiddenByDefault" -Value 1 -PropertyType DWORD -Force

# Block enumeration
New-Item -Path $nonEnumPath -Force | Out-Null
New-ItemProperty -Path $nonEnumPath -Name "{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Value 1 -PropertyType DWORD -Force

Write-Output "Permanent system-wide removal applied. Restart explorer.exe."
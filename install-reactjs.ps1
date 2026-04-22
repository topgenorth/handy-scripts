# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force

# Install Node.js LTS (includes npm)
winget install -e --id OpenJS.NodeJS.LTS

# # Install Git
# winget install -e --id Git.Git

# # Install VS Code
# winget install -e --id Microsoft.VisualStudioCode

Write-Host "Installation complete. Restart PowerShell and verify: node -v, npm -v, git --version, code --version"
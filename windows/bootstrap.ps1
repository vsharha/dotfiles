# Wait for network connectivity
Write-Host "Waiting for network..."
while (-not (Test-NetConnection -ComputerName 8.8.8.8 -InformationLevel Quiet)) {
    Start-Sleep -Seconds 5
}

# Fetch and import app list
Write-Host "Installing apps..."
$appsUrl = "https://raw.githubusercontent.com/vsharha/dotfiles/main/windows/apps.json"
$appsJson = (Invoke-WebRequest -Uri $appsUrl -UseBasicParsing).Content
$tmpFile = "$env:TEMP\apps.json"
$appsJson | Out-File -FilePath $tmpFile -Encoding utf8

winget import --import-file $tmpFile --ignore-unavailable --no-upgrade --accept-package-agreements --accept-source-agreements

Write-Host "Done."

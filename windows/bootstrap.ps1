$ErrorActionPreference = "Stop"

Write-Host "Waiting for network..."
# A failed probe is the expected state while waiting, so keep its error and
# warning output from ending the script under the Stop preference above.
while (-not (Test-NetConnection -ComputerName 8.8.8.8 -InformationLevel Quiet `
        -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)) {
    Start-Sleep -Seconds 5
}

Write-Host "Installing apps..."
$appsUrl = "https://raw.githubusercontent.com/vsharha/dotfiles/main/windows/apps.json"
$appsJson = (Invoke-WebRequest -Uri $appsUrl -UseBasicParsing).Content
$tmpFile = "$env:TEMP\apps.json"
$appsJson | Out-File -FilePath $tmpFile -Encoding utf8

winget import --import-file $tmpFile --ignore-unavailable --no-upgrade --accept-package-agreements --accept-source-agreements

# $ErrorActionPreference does not apply to native executables; check explicitly
# so a failed import is not reported as a successful run.
if ($LASTEXITCODE -ne 0) {
    Write-Host "winget import failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

Write-Host "Done."

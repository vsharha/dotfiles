$ErrorActionPreference = "Stop"

$appsUrl = "https://raw.githubusercontent.com/vsharha/dotfiles/main/windows/apps.json"
$downloadAttempts = 6
$downloadTimeoutSeconds = 15
$downloadRetrySeconds = 5
$appsJson = $null

for ($attempt = 1; $attempt -le $downloadAttempts; $attempt++) {
    Write-Host "Downloading app manifest (attempt $attempt of $downloadAttempts)..."
    try {
        $appsJson = (Invoke-WebRequest -Uri $appsUrl -UseBasicParsing `
            -TimeoutSec $downloadTimeoutSeconds).Content
        break
    }
    catch {
        if ($attempt -eq $downloadAttempts) {
            throw "Could not download the app manifest after $downloadAttempts attempts: $($_.Exception.Message)"
        }

        Write-Host "Download failed; retrying in $downloadRetrySeconds seconds..."
        Start-Sleep -Seconds $downloadRetrySeconds
    }
}

Write-Host "Installing apps..."
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

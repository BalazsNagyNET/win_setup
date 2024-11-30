# Ensure the script runs with admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as an administrator." -ForegroundColor Red
    exit
}

# Install Chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey not found. Installing Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey is already installed." -ForegroundColor Green
}

# Refresh the environment to ensure `choco` is available
$env:Path += ";$((Get-Command choco).Path)"

# Install required applications using Chocolatey
Write-Host "Installing applications using Chocolatey..." -ForegroundColor Cyan

$apps = @(
    @{Name = "Google Chrome"; Id = "googlechrome"},
    @{Name = "qBittorrent"; Id = "qbittorrent"},
    @{Name = "KeePass"; Id = "keepass"},
    @{Name = "Google Drive"; Id = "google-drive"},
    @{Name = "VLC Media Player"; Id = "vlc"},
    @{Name = "Visual Studio Code"; Id = "vscode"},
    @{Name = "Total Commander"; Id = "totalcommander"}
)

foreach ($app in $apps) {
    Write-Host "Installing $($app.Name)..." -ForegroundColor Yellow
    choco install $($app.Id) -y --no-progress
}

# Open and close qBittorrent to create the configuration file
Write-Host "Opening and closing qBittorrent to create the configuration file..." -ForegroundColor Cyan
Start-Process -FilePath "$env:ProgramFiles\qBittorrent\qbittorrent.exe" -ArgumentList "--confirm-legal-notice" -NoNewWindow
Start-Sleep -Seconds 5  # Wait for 5 seconds to allow the configuration file to be created
Stop-Process -Name "qbittorrent" -Force

# Configure qBittorrent to set the default download directory
Write-Host "Configuring qBittorrent download directory..." -ForegroundColor Cyan
$qBittorrentConfigPath = "$env:APPDATA\qBittorrent\qBittorrent.ini"
$downloadDir = "C:\Torrents"

if (-not (Test-Path $downloadDir)) {
    New-Item -Path $downloadDir -ItemType Directory | Out-Null
}

if (Test-Path $qBittorrentConfigPath) {
    (Get-Content $qBittorrentConfigPath) -replace "^\[BitTorrent\].*DownloadFolder=.*$", "`[BitTorrent]`nDownloadFolder=$downloadDir" |
        Set-Content $qBittorrentConfigPath
    Write-Host "Download directory set to $downloadDir" -ForegroundColor Green
} else {
    Write-Host "Failed to create qBittorrent configuration file. Please check manually." -ForegroundColor Red
}

# Set Google Chrome as the default browser
Write-Host "Setting Google Chrome as the default browser..." -ForegroundColor Cyan
Start-Process -FilePath "$env:ProgramFiles\Google\Chrome\Application\chrome.exe" -ArgumentList "--make-default-browser" -NoNewWindow -Wait

Write-Host "All applications installed and configured successfully!" -ForegroundColor Green


# TODOS
# Fix qBittorrent configuration file creation
# Make chrome default browser
# Setup google drive sync for keepass database file
# Setup keepass sync with google drive
# Make VLC default media player
# Make VSCode default text editor
# Show hidden files and folders
# Show file extensions
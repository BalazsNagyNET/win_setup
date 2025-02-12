# Ensure the script runs with admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as an administrator." -ForegroundColor Red
    exit
}

# Function to install Chocolatey
function Install-Chocolatey {
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
}

# Function to install and configure Google Chrome
function Install-Configure-Chrome {
    Write-Host "Installing Google Chrome..." -ForegroundColor Yellow
    choco install googlechrome -y --no-progress
}

# Function to install and configure qBittorrent
function Install-Configure-qBittorrent {
    Write-Host "Installing qBittorrent..." -ForegroundColor Yellow
    choco install qbittorrent -y --no-progress

    Write-Host "Opening and closing qBittorrent to create the configuration file..." -ForegroundColor Cyan
    Start-Process -FilePath "$env:ProgramFiles\qBittorrent\qbittorrent.exe" -ArgumentList "--confirm-legal-notice" -NoNewWindow
    Write-Host "Waiting for 10 seconds to allow the configuration file to be created..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Stop-Process -Name "qbittorrent" -Force

    Write-Host "Configuring qBittorrent download directory..." -ForegroundColor Cyan
    $qBittorrentConfigPath = "$env:APPDATA\qBittorrent\qBittorrent.ini"
    $downloadDir = "C:\\Torrents"

    if (-not (Test-Path $downloadDir)) {
        New-Item -Path $downloadDir -ItemType Directory | Out-Null
    }

    $newSettings = @"
Session\DefaultSavePath=$downloadDir
Session\TorrentExportDirectory=$downloadDir
"@
    $configContent = Get-Content $qBittorrentConfigPath

    if ($configContent -match "^\[BitTorrent\]") {
        $configContent = $configContent -replace "(\[BitTorrent\].*?)(?=\[|\z)", "`$1`n$newSettings"
    } else {
        $configContent += "`n[BitTorrent]`n$newSettings"
    }

    $configContent | Set-Content $qBittorrentConfigPath
}

# Function to install and configure KeePass
function Install-Configure-KeePass {
    Write-Host "Installing KeePass..." -ForegroundColor Yellow
    choco install keepass -y --no-progress

    Write-Host "Adding enforced configuration file for KeePass with database file sync trigger..." -ForegroundColor Cyan
    $keepassConfigPath = "$env:ProgramFiles\KeePass Password Safe 2\KeePass.config.enforced.xml"
    $configContent = @"
<?xml version=`"1.0`" encoding=`"utf-8`"?>
<Configuration xmlns:xsd=`"http://www.w3.org/2001/XMLSchema`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`">
    <Application>
        <TriggerSystem>
            <Triggers>
                <Trigger>
                    <Guid>8H/489TIqEGfVW0MMFuSSQ==</Guid>
                    <Name>Sync2Drive</Name>
                    <Events>
                        <Event>
                            <TypeGuid>lcGm/XJ8QMei+VsPoJljHA==</TypeGuid>
                            <Parameters>
                                <Parameter>0</Parameter>
                                <Parameter />
                            </Parameters>
                        </Event>
                    </Events>
                    <Conditions />
                    <Actions>
                        <Action>
                            <TypeGuid>tkamn96US7mbrjykfswQ6g==</TypeGuid>
                            <Parameters>
                                <Parameter />
                                <Parameter>0</Parameter>
                            </Parameters>
                        </Action>
                        <Action>
                            <TypeGuid>Iq135Bd4Tu2ZtFcdArOtTQ==</TypeGuid>
                            <Parameters>
                                <Parameter>g:\My Drive\KeePass\KeePass.kdbx</Parameter>
                                <Parameter />
                                <Parameter />
                            </Parameters>
                        </Action>
                        <Action>
                            <TypeGuid>tkamn96US7mbrjykfswQ6g==</TypeGuid>
                            <Parameters>
                                <Parameter />
                                <Parameter>1</Parameter>
                            </Parameters>
                        </Action>
                    </Actions>
                </Trigger>
            </Triggers>
        </TriggerSystem>
    </Application>
</Configuration>
"@
    $configContent | Out-File -FilePath $keepassConfigPath -Encoding UTF8
    Write-Host "KeePass enforced configuration file added." -ForegroundColor Green
}

# Function to install and configure Google Drive
function Install-Configure-GoogleDrive {
    Write-Host "Installing Google Drive..." -ForegroundColor Yellow
    choco install google-drive -y --no-progress
}

# Function to install and configure VLC Media Player
function Install-Configure-VLC {
    Write-Host "Installing VLC Media Player..." -ForegroundColor Yellow
    choco install vlc -y --no-progress
}

# Function to install and configure Visual Studio Code
function Install-Configure-VSCode {
    Write-Host "Installing Visual Studio Code..." -ForegroundColor Yellow
    choco install vscode -y --no-progress
}

# Function to install and configure Total Commander
function Install-Configure-TotalCommander {
    Write-Host "Installing Total Commander..." -ForegroundColor Yellow
    choco install totalcommander -y --no-progress
}

# Function to copy Total Commander key
function Copy-TotalCommanderKey {
    Write-Host "Copying Total Commander key..." -ForegroundColor Yellow
    $sourcePath = "g:\My Drive\TotalCommanderKey\wincmd.key"
    $destinationPath = "c:\Program Files\totalcmd\wincmd.key"

    Write-Host "Starting Google Drive. Please log in to your account." -ForegroundColor Cyan
    Start-Process -FilePath "c:\Program Files\Google\Drive File Stream\launch.bat"
    Read-Host "Press Enter to continue..."

    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destinationPath -Force
        Write-Host "Total Commander key copied successfully." -ForegroundColor Green
    } else {
        Write-Host "Total Commander key not found at source path." -ForegroundColor Red
    }
}

# Function to install and configure Git
function Install-Configure-Git {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    choco install git -y --no-progress
}

# Function to install and configure GitExtensions
function Install-Configure-GitExtensions {
    Write-Host "Installing GitExtensions..." -ForegroundColor Yellow
    choco install gitextensions -y --no-progress
}

# Function to install and configure AutoHotkey
function Install-Configure-AutoHotkey {
    Write-Host "Installing AutoHotkey..." -ForegroundColor Yellow
    choco install autohotkey -y --no-progress
}

# Function to show hidden files and folders
function Show-HiddenFilesAndFolders {
    Write-Host "Showing hidden files and folders..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
    Write-Host "Hidden files and folders are now visible." -ForegroundColor Green
}

# Function to show file extensions
function Show-FileExtensions {
    Write-Host "Showing file extensions..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    Write-Host "File extensions are now visible." -ForegroundColor Green
}

# Main script execution
Install-Chocolatey

Install-Configure-Chrome
Install-Configure-qBittorrent
Install-Configure-KeePass
Install-Configure-GoogleDrive
Install-Configure-VLC
Install-Configure-VSCode
Install-Configure-TotalCommander
Install-Configure-Git
Install-Configure-GitExtensions
Install-Configure-AutoHotkey

Show-HiddenFilesAndFolders
Show-FileExtensions

Copy-TotalCommanderKey

Write-Host "All applications installed and configured successfully!" -ForegroundColor Green

# TODOS
# Make chrome default browser - not easy
# Make VLC default media player
# Make VSCode default text editor
# Setup google drive sync for keepass database file
# Setup keepass sync with google drive

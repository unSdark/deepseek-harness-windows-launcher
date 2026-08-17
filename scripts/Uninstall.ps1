[CmdletBinding()]
param(
    [switch]$RemoveLog,
    [string]$InstallDirectory = (Join-Path $env:USERPROFILE '.dsh\launcher'),
    [string]$DesktopDirectory = [Environment]::GetFolderPath('Desktop')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$shortcutPath = Join-Path $desktopDirectory 'DeepSeek Harness.lnk'
$installedFiles = @(
    (Join-Path $InstallDirectory 'Launch-DeepSeek-Harness.vbs'),
    (Join-Path $InstallDirectory 'DeepSeek-Harness.ico')
)

if ($RemoveLog) {
    $installedFiles += (Join-Path $InstallDirectory 'dsh-web.log')
}

if (Test-Path -LiteralPath $shortcutPath -PathType Leaf) {
    Remove-Item -LiteralPath $shortcutPath -Force
    Write-Host "Removed shortcut: $shortcutPath"
}

foreach ($file in $installedFiles) {
    if (Test-Path -LiteralPath $file -PathType Leaf) {
        Remove-Item -LiteralPath $file -Force
        Write-Host "Removed file:     $file"
    }
}

if (Test-Path -LiteralPath $InstallDirectory -PathType Container) {
    $remainingItems = @(Get-ChildItem -LiteralPath $InstallDirectory -Force)
    if ($remainingItems.Count -eq 0) {
        Remove-Item -LiteralPath $InstallDirectory -Force
        Write-Host "Removed directory: $InstallDirectory"
    }
    elseif (-not $RemoveLog) {
        Write-Host "Kept directory and log: $InstallDirectory"
    }
}

Write-Host 'DeepSeek Harness itself and other .dsh settings were not removed.'

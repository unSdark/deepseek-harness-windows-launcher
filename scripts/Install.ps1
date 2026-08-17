[CmdletBinding()]
param(
    [switch]$InstallDeepSeekHarness,
    [string]$DshCommand = (Join-Path $env:APPDATA 'npm\dsh.cmd'),
    [string]$InstallDirectory = (Join-Path $env:USERPROFILE '.dsh\launcher'),
    [string]$DesktopDirectory = [Environment]::GetFolderPath('Desktop'),
    [string]$WorkingDirectory = [Environment]::GetFolderPath('MyDocuments')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourceLauncher = Join-Path $repositoryRoot 'src\Launch-DeepSeek-Harness.vbs'
$sourceIcon = Join-Path $repositoryRoot 'assets\DeepSeek-Harness.ico'

if (-not (Test-Path -LiteralPath $sourceLauncher -PathType Leaf)) {
    throw "Launcher source was not found: $sourceLauncher"
}

if (-not (Test-Path -LiteralPath $sourceIcon -PathType Leaf)) {
    throw "Icon was not found: $sourceIcon"
}

if (-not (Test-Path -LiteralPath $DshCommand -PathType Leaf)) {
    if (-not $InstallDeepSeekHarness) {
        throw "dsh.cmd was not found at '$DshCommand'. Install @deepseek-ai/dsh first, or rerun with -InstallDeepSeekHarness."
    }

    $npm = Get-Command npm.cmd -ErrorAction Stop
    Write-Host 'Installing @deepseek-ai/dsh globally...'
    & $npm.Source install --global '@deepseek-ai/dsh'
    if ($LASTEXITCODE -ne 0) {
        throw "npm exited with code $LASTEXITCODE"
    }

    if (-not (Test-Path -LiteralPath $DshCommand -PathType Leaf)) {
        throw "DeepSeek Harness installation completed, but dsh.cmd was not found at '$DshCommand'."
    }
}

New-Item -ItemType Directory -Path $InstallDirectory -Force | Out-Null

$installedLauncher = Join-Path $InstallDirectory 'Launch-DeepSeek-Harness.vbs'
$installedIcon = Join-Path $InstallDirectory 'DeepSeek-Harness.ico'
Copy-Item -LiteralPath $sourceLauncher -Destination $installedLauncher -Force
Copy-Item -LiteralPath $sourceIcon -Destination $installedIcon -Force

$shortcutPath = Join-Path $desktopDirectory 'DeepSeek Harness.lnk'
$wscriptPath = Join-Path $env:WINDIR 'System32\wscript.exe'

New-Item -ItemType Directory -Path $DesktopDirectory -Force | Out-Null

$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $wscriptPath
$shortcut.Arguments = '"' + $installedLauncher + '"'
$shortcut.WorkingDirectory = $WorkingDirectory
$shortcut.IconLocation = $installedIcon + ',0'
$shortcut.Description = 'Start the DeepSeek Harness Web UI'
$shortcut.WindowStyle = 1
$shortcut.Save()

& (Join-Path $env:WINDIR 'System32\cscript.exe') //nologo $installedLauncher /test
if ($LASTEXITCODE -ne 0) {
    throw "Launcher self-test failed with exit code $LASTEXITCODE"
}

Write-Host "Installed launcher: $installedLauncher"
Write-Host "Created shortcut:   $shortcutPath"

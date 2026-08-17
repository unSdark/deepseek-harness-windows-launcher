[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
    (Join-Path $repositoryRoot 'README.md'),
    (Join-Path $repositoryRoot 'LICENSE'),
    (Join-Path $repositoryRoot 'THIRD_PARTY_NOTICES.md'),
    (Join-Path $repositoryRoot 'src\Launch-DeepSeek-Harness.vbs'),
    (Join-Path $repositoryRoot 'scripts\Install.ps1'),
    (Join-Path $repositoryRoot 'scripts\Uninstall.ps1'),
    (Join-Path $repositoryRoot 'assets\DeepSeek-Harness.ico'),
    (Join-Path $repositoryRoot 'assets\DeepSeek-Harness-preview.png')
)

foreach ($requiredFile in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required file is missing: $requiredFile"
    }
}

$powerShellFiles = Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1' -File
foreach ($powerShellFile in $powerShellFiles) {
    $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        $powerShellFile.FullName,
        [ref]$tokens,
        [ref]$parseErrors
    ) | Out-Null

    if ($parseErrors.Count -gt 0) {
        $details = $parseErrors | ForEach-Object { $_.Message }
        throw "PowerShell parse error in '$($powerShellFile.Name)': $($details -join '; ')"
    }
}

$launcher = Join-Path $repositoryRoot 'src\Launch-DeepSeek-Harness.vbs'
$cscript = Join-Path $env:WINDIR 'System32\cscript.exe'
& $cscript //nologo $launcher /syntax
if ($LASTEXITCODE -ne 0) {
    throw "VBScript syntax check failed with exit code $LASTEXITCODE"
}

$icon = Join-Path $repositoryRoot 'assets\DeepSeek-Harness.ico'
$iconBytes = [System.IO.File]::ReadAllBytes($icon)
$expectedHeader = [byte[]](0, 0, 1, 0, 1, 0)
if ($iconBytes.Length -lt 30) {
    throw 'ICO file is unexpectedly small.'
}

for ($index = 0; $index -lt $expectedHeader.Length; $index++) {
    if ($iconBytes[$index] -ne $expectedHeader[$index]) {
        throw 'ICO header is invalid.'
    }
}

$imageOffset = [BitConverter]::ToUInt32($iconBytes, 18)
$pngSignature = [byte[]](0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a)
for ($index = 0; $index -lt $pngSignature.Length; $index++) {
    if ($iconBytes[$imageOffset + $index] -ne $pngSignature[$index]) {
        throw 'ICO file does not contain the expected embedded PNG image.'
    }
}

Write-Host "Validated $($requiredFiles.Count) required files."
Write-Host "Parsed $($powerShellFiles.Count) PowerShell scripts."
Write-Host 'VBScript syntax and ICO structure are valid.'

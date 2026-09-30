Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$versionPath = Join-Path $repoRoot 'src/version.txt'
$notesPath = Join-Path $repoRoot 'src/release-notes.txt'

if (-not (Test-Path -LiteralPath $versionPath)) {
    throw "Version file not found: $versionPath"
}

$version = (Get-Content -LiteralPath $versionPath -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') {
    throw "Version '$version' is not valid SemVer in MAJOR.MINOR.PATCH form."
}

if (-not (Test-Path -LiteralPath $notesPath)) {
    throw "Release notes not found: $notesPath"
}

$notes = Get-Content -LiteralPath $notesPath -Raw
if ($notes -match '(?i)TODO|CHANGEME|SECRET') {
    throw 'Release notes contain a forbidden placeholder.'
}

Write-Host "Validation successful for version $version"

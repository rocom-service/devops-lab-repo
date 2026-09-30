param(
    [Parameter(Mandatory)]
    [string]$OutputPath,

    [string]$Configuration = 'Release'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repoRoot 'src'

New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $sourcePath 'version.txt') -Destination $OutputPath
Copy-Item -LiteralPath (Join-Path $sourcePath 'release-notes.txt') -Destination $OutputPath

$metadata = [ordered]@{
    configuration = $Configuration
    builtAtUtc = [DateTime]::UtcNow.ToString('o')
}
$metadata | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $OutputPath 'build-metadata.json') -Encoding utf8

Write-Host "Package created at $OutputPath"

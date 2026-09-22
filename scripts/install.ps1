param([string]$CodexRoot = $env:CODEX_HOME)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($CodexRoot)) {
    $CodexRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
}
$CodexRoot = [System.IO.Path]::GetFullPath($CodexRoot)
$source = Join-Path (Split-Path -Parent $PSScriptRoot) 'pet'
$manifestPath = Join-Path $source 'pet.json'
$spritePath = Join-Path $source 'spritesheet.png'
if (!(Test-Path -LiteralPath $manifestPath -PathType Leaf) -or !(Test-Path -LiteralPath $spritePath -PathType Leaf)) {
    throw 'Missing pet/pet.json or pet/spritesheet.png. Extract the complete project first.'
}
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($manifest.spriteVersionNumber -ne 1 -or $manifest.spritesheetPath -ne 'spritesheet.png') {
    throw 'Expected spriteVersionNumber 1 and spritesheet.png.'
}
$petRoot = Join-Path $CodexRoot 'pets'
$target = Join-Path $petRoot 'daimao'
if (Test-Path -LiteralPath $target) {
    $backupRoot = Join-Path $CodexRoot 'pet-backups'
    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    $backup = Join-Path $backupRoot ('daimao-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '-' + [Guid]::NewGuid().ToString('N').Substring(0,8))
    Copy-Item -LiteralPath $target -Destination $backup -Recurse
    Write-Output "Previous version backed up: $backup"
}
New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -LiteralPath $spritePath -Destination (Join-Path $target 'spritesheet.png') -Force
Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $target 'pet.json') -Force
Write-Output "Daimao installed: $target"
Write-Output 'Open Codex Settings > Pets and select the pet. Restart Codex if the old image remains.'

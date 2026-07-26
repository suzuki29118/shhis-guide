param(
    [string]$ModeAJson = (Join-Path $env:USERPROFILE "Downloads\mode-a.json"),
    [string]$ModeBJson = (Join-Path $env:USERPROFILE "Downloads\mode-b.json"),
    [string]$Message = "update SHHis guide data"
)

$ErrorActionPreference = "Stop"

function Write-Step($text) {
    Write-Host ""
    Write-Host "==> $text" -ForegroundColor Cyan
}

function Test-JsonFile($path) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "File not found: $path"
    }
    Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
}

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $repo

Write-Step "Checking Git repository"
git rev-parse --is-inside-work-tree | Out-Null
if ($LASTEXITCODE -ne 0) { throw "This folder is not a Git repository." }

$gitName = git config user.name
$gitEmail = git config user.email
if (-not $gitName) {
    git config user.name "suzuki29118"
}
if (-not $gitEmail) {
    git config user.email "suzuki29118@users.noreply.github.com"
}

Write-Step "Copying exported data files when they exist in Downloads"
New-Item -ItemType Directory -Force -Path "data" | Out-Null

if ((Test-Path -LiteralPath $ModeAJson) -and (Test-Path -LiteralPath $ModeBJson)) {
    Test-JsonFile $ModeAJson
    Test-JsonFile $ModeBJson
    Copy-Item -LiteralPath $ModeAJson -Destination "data\mode-a.json" -Force
    Copy-Item -LiteralPath $ModeBJson -Destination "data\mode-b.json" -Force
    Write-Host "Copied: $ModeAJson -> data\mode-a.json"
    Write-Host "Copied: $ModeBJson -> data\mode-b.json"
} else {
    Write-Host "Downloads does not contain both mode-a.json and mode-b.json. Publishing current data files instead."
}

Write-Step "Validating website data files"
Test-JsonFile "data\mode-a.json"
Test-JsonFile "data\mode-b.json"

Write-Step "Current changes"
git status --short

$hasChanges = git status --porcelain
if (-not $hasChanges) {
    Write-Host "No changes to publish."
    exit 0
}

Write-Step "Committing changes"
git add --all
if ($LASTEXITCODE -ne 0) { throw "git add failed." }
git commit -m $Message
if ($LASTEXITCODE -ne 0) { throw "git commit failed." }

Write-Step "Pushing to GitHub"
git push origin main
if ($LASTEXITCODE -ne 0) { throw "git push failed." }

Write-Host ""
Write-Host "Done. Wait a few minutes, then check https://210322.xyz/" -ForegroundColor Green

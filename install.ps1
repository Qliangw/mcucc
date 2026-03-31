<#
.SYNOPSIS
MCUCC Cloud Bootstrapper (Network-Aware)
.DESCRIPTION
Installs the MCUCC High-Agency Rules interactively. Detects if running locally or standalone, and fetches missing files from GitHub on the fly.
#>
param(
    [string]$TargetDirectory,
    [string]$Agents
)

$BaseUrl = "https://raw.githubusercontent.com/Qliangw/mcucc/main"

function Get-McuccFile {
    param([string]$RelativePath, [string]$Destination)
    $LocalPath = Join-Path -Path $PSScriptRoot -ChildPath $RelativePath
    if (Test-Path $LocalPath) {
        Copy-Item -Path $LocalPath -Destination $Destination -Force
    } else {
        $RemoteUrl = "$BaseUrl/$($RelativePath -replace '\\', '/')"
        Write-Host "    [Cloud Fetch] Pulling -> $RemoteUrl" -ForegroundColor DarkGray
        try {
            Invoke-WebRequest -Uri $RemoteUrl -OutFile $Destination -UseBasicParsing | Out-Null
        } catch {
            Write-Host "[ERROR] Network request failed. Cannot access raw.githubusercontent.com" -ForegroundColor Red
        }
    }
}

function Get-McuccContent {
    param([string]$RelativePath)
    $LocalPath = Join-Path -Path $PSScriptRoot -ChildPath $RelativePath
    if (Test-Path $LocalPath) {
        return Get-Content $LocalPath -Raw
    } else {
        $RemoteUrl = "$BaseUrl/$($RelativePath -replace '\\', '/')"
        Write-Host "    [Cloud Fetch] Streaming -> $RemoteUrl" -ForegroundColor DarkGray
        try {
            return (Invoke-WebRequest -Uri $RemoteUrl -UseBasicParsing).Content
        } catch {
            Write-Host "[ERROR] Failed to read remote source file." -ForegroundColor Red
            return ""
        }
    }
}

if (-not $TargetDirectory) {
    Write-Host "`n[MCUCC Installer] Welcome. Enter the absolute path of your target MCU project directory?" -ForegroundColor Cyan
    $TargetDirectory = Read-Host "(Press ENTER to use current directory: $((Get-Location).Path))"
    if ([string]::IsNullOrWhiteSpace($TargetDirectory)) {
        $TargetDirectory = (Get-Location).Path
    }
}

$TargetDirectory = Resolve-Path $TargetDirectory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
if (-not (Test-Path $TargetDirectory)) {
    Write-Host "[ERROR] Target directory not found: $TargetDirectory. Please check and try again." -ForegroundColor Red
    exit 1
}

if (-not $Agents) {
    Write-Host "`n[MCUCC Cloud Deployment] Please select the AI environments you intend to use (Comma separated):" -ForegroundColor Cyan
    Write-Host "  [1] Cursor IDE        (Injects .cursor/rules)"
    Write-Host "  [2] Claude / Terminal (Fetches SKILL.md to clipboard)"
    Write-Host "  [3] Native .agents    (Clones full structure for .agents)"
    Write-Host "  [4] Install ALL       (Everything)"
    $Agents = Read-Host "Enter numbers (e.g. 1,3 or 4)"
}

$Selections = @()
if ($Agents -match "4") { $Selections = 1,2,3 } else { $Selections = $Agents -split "," | ForEach-Object { $_.Trim() } }

Write-Host "`n=== Securing project at: $TargetDirectory ===" -ForegroundColor Yellow

if ($Selections -contains "1") {
    $CursorRulesPath = Join-Path -Path $TargetDirectory -ChildPath ".cursor\rules"
    if (-not (Test-Path $CursorRulesPath)) { New-Item -ItemType Directory -Force -Path $CursorRulesPath | Out-Null }
    Get-McuccFile -RelativePath "cursor\rules\mcucc.mdc" -Destination "$CursorRulesPath\mcucc.mdc"
    Write-Host "[OK] Cursor IDE rules injected -> $CursorRulesPath\mcucc.mdc" -ForegroundColor Green
}

if ($Selections -contains "2") {
    $SkillContent = Get-McuccContent -RelativePath "skills\mcucc\SKILL.md"
    if (-not [string]::IsNullOrWhiteSpace($SkillContent)) {
        $SkillContent | Set-Clipboard
        Write-Host "[OK] Claude protocol fetched to CLIPBOARD. Just press Ctrl+V in Claude Project Instructions!" -ForegroundColor Green
        $ReadmePath = Join-Path -Path $TargetDirectory -ChildPath "MCUCC_CLAUDE_README.txt"
        "Because you used the cloud bootstrapper, no local files were preserved.`nThe full MCUCC protocol is now in your system clipboard (Ctrl+C). Paste it to your AI!`nIf you lost it, re-run the script or visit: $BaseUrl/skills/mcucc/SKILL.md" | Out-File -FilePath $ReadmePath
        Write-Host "     [Info] A text reminder was placed at -> $ReadmePath" -ForegroundColor DarkGreen
    }
}

if ($Selections -contains "3") {
    $AgentsPath = Join-Path -Path $TargetDirectory -ChildPath ".agents\skills\mcucc"
    if (-not (Test-Path $AgentsPath)) { New-Item -ItemType Directory -Force -Path $AgentsPath | Out-Null }
    Get-McuccFile -RelativePath "skills\mcucc\SKILL.md" -Destination "$AgentsPath\SKILL.md"
    
    $ScriptsDest = Join-Path -Path $AgentsPath -ChildPath "scripts"
    if (-not (Test-Path $ScriptsDest)) { New-Item -ItemType Directory -Force -Path $ScriptsDest | Out-Null }
    Get-McuccFile -RelativePath "scripts\check_env.ps1" -Destination "$ScriptsDest\check_env.ps1"
    Write-Host "[OK] Native .agents standardized structure deployed -> $AgentsPath" -ForegroundColor Green
}

Write-Host "`n[MCUCC Bootstrapper] 🎯 Deployment complete! Your project is now guided by Principal Architect standards.`n" -ForegroundColor Cyan

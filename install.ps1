<#
.SYNOPSIS
MCUCC Cloud Bootstrapper (Network-Aware)
.DESCRIPTION
Installs the MCUCC High-Agency Rules interactively. Detects if running locally or standalone, and fetches missing files from raw.githubusercontent.com on the fly.
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
            Write-Host "[ERROR] 网络请求失败，请检查网络是否能访问 raw.githubusercontent.com" -ForegroundColor Red
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
            Write-Host "[ERROR] 法典源读取失败。" -ForegroundColor Red
            return ""
        }
    }
}

if (-not $TargetDirectory) {
    Write-Host "`n[MCUCC Installer] 欢迎使用。请输入您要注入 MCUCC 极客协议的工程绝对路径？" -ForegroundColor Cyan
    $TargetDirectory = Read-Host "（直接按 ENTER 键代表当前路径: $((Get-Location).Path)）"
    if ([string]::IsNullOrWhiteSpace($TargetDirectory)) {
        $TargetDirectory = (Get-Location).Path
    }
}

$TargetDirectory = Resolve-Path $TargetDirectory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
if (-not (Test-Path $TargetDirectory)) {
    Write-Host "[ERROR] Target directory not found: $TargetDirectory. 目录可能不存在，请检查后重试。" -ForegroundColor Red
    exit 1
}

if (-not $Agents) {
    Write-Host "`n[MCUCC 一键部署系统] 请为您即将部署的项目选择您所拥有的 AI 组合（云端流式拉取）：" -ForegroundColor Cyan
    Write-Host "  [1] Cursor IDE        (向目标写入不可见的 .cursor/rules)"
    Write-Host "  [2] Claude / 纯终端   (网络抓取万字法则并送入剪贴板备用)"
    Write-Host "  [3] 原生 .agents 规范 (全库拉取并建立技能挂载点)"
    Write-Host "  [4] 全系静默全装      (全部都要！)"
    $Agents = Read-Host "请输入如 1,3，或单打 4"
}

$Selections = @()
if ($Agents -match "4") { $Selections = 1,2,3 } else { $Selections = $Agents -split "," | ForEach-Object { $_.Trim() } }

Write-Host "`n=== 开始为工程分配安全屋: $TargetDirectory ===" -ForegroundColor Yellow

if ($Selections -contains "1") {
    $CursorRulesPath = Join-Path -Path $TargetDirectory -ChildPath ".cursor\rules"
    if (-not (Test-Path $CursorRulesPath)) { New-Item -ItemType Directory -Force -Path $CursorRulesPath | Out-Null }
    Get-McuccFile -RelativePath "cursor\rules\mcucc.mdc" -Destination "$CursorRulesPath\mcucc.mdc"
    Write-Host "[OK] Cursor IDE 核心规则注入完成 -> $CursorRulesPath\mcucc.mdc" -ForegroundColor Green
}

if ($Selections -contains "2") {
    $SkillContent = Get-McuccContent -RelativePath "skills\mcucc\SKILL.md"
    if (-not [string]::IsNullOrWhiteSpace($SkillContent)) {
        $SkillContent | Set-Clipboard
        Write-Host "[OK] Claude 准则已由云端接出送入剪贴板！可以直接去 Claude Project 内 Ctrl+V 粘贴啦！" -ForegroundColor Green
        $ReadmePath = Join-Path -Path $TargetDirectory -ChildPath "MCUCC_CLAUDE_README.txt"
        "由于您选用了单独下载引导装载程序，原始文件未留存。`n完整的纯净架构法则已经存在于您的系统剪贴板（Ctrl+C）中，请直接贴给AI！`n如果您丢失了它，请重新运行或访问：$BaseUrl/skills/mcucc/SKILL.md" | Out-File -FilePath $ReadmePath
        Write-Host "     [备忘] 为了防止您搞掉这段剪贴板，已经贴心在根目录拉出一份备忘说明 -> $ReadmePath" -ForegroundColor DarkGreen
    }
}

if ($Selections -contains "3") {
    $AgentsPath = Join-Path -Path $TargetDirectory -ChildPath ".agents\skills\mcucc"
    if (-not (Test-Path $AgentsPath)) { New-Item -ItemType Directory -Force -Path $AgentsPath | Out-Null }
    Get-McuccFile -RelativePath "skills\mcucc\SKILL.md" -Destination "$AgentsPath\SKILL.md"
    
    $ScriptsDest = Join-Path -Path $AgentsPath -ChildPath "scripts"
    if (-not (Test-Path $ScriptsDest)) { New-Item -ItemType Directory -Force -Path $ScriptsDest | Out-Null }
    Get-McuccFile -RelativePath "scripts\check_env.ps1" -Destination "$ScriptsDest\check_env.ps1"
    Write-Host "[OK] 原生生态 .agents 环境规范已从拉取完成并落盘 -> $AgentsPath" -ForegroundColor Green
}

Write-Host "`n[MCUCC Bootstrapper] 🎯 部署完毕！您的工程已被首席嵌入式架构师云端防线接管！`n" -ForegroundColor Cyan

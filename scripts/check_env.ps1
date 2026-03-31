param([switch]$Install)

$tools = @(
    @{ Name = 'arm-none-eabi-gcc'; Command = 'arm-none-eabi-gcc --version'; ScoopPkg='gcc-arm-embedded'; WingetId='GnuArmEmbeddedToolchain.GnuArmEmbeddedToolchain' },
    @{ Name = 'make'; Command = 'make --version'; ScoopPkg='make'; WingetId='GnuWin32.Make' },
    @{ Name = 'openocd'; Command = 'openocd --version'; ScoopPkg='openocd'; WingetId='' }
)

$missingTools = @()

foreach ($tool in $tools) {
    Write-Host "Checking for $($tool.Name)... " -NoNewline
    
    # Check if command exists in PATH
    $cmdStatus = Get-Command $tool.Name -ErrorAction SilentlyContinue
    if ($cmdStatus) {
        Write-Host "[FOUND]" -ForegroundColor Green
    } else {
        Write-Host "[MISSING]" -ForegroundColor Red
        $missingTools += $tool
    }
}

if ($missingTools.Count -eq 0) {
    Write-Host "`nAll required MCU tools are installed and ready!" -ForegroundColor Green
    exit 0
}

Write-Host "`nMissing tools detected." -ForegroundColor Yellow

if ($Install) {
    Write-Host "Attempting automatic installation..." -ForegroundColor Cyan
    # Check if scoop or winget is available
    $hasScoop = [bool](Get-Command 'scoop' -ErrorAction SilentlyContinue)
    $hasWinget = [bool](Get-Command 'winget' -ErrorAction SilentlyContinue)

    foreach ($tool in $missingTools) {
        if ($hasScoop -and $tool.ScoopPkg) {
            Write-Host "Installing $($tool.Name) via Scoop..." 
            scoop install $tool.ScoopPkg
        } elseif ($hasWinget -and $tool.WingetId) {
            Write-Host "Installing $($tool.Name) via Winget..."
            winget install -e --id $($tool.WingetId)
        } else {
            Write-Host "Cannot auto-install $($tool.Name). Please install manually and add to PATH." -ForegroundColor Red
        }
    }
} else {
    Write-Host "Run this script with the -Install flag to attempt automatic installation:`n  .\check_env.ps1 -Install" -ForegroundColor Cyan
    exit 1
}

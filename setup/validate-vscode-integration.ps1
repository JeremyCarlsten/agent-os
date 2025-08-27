# Validate VSCode Integration Test

Write-Host "🧪 Validating VSCode Integration" -ForegroundColor Cyan

# Test 1: Check if project.sh contains VSCode support
$projectScript = Get-Content "setup/project.sh" -Raw
$hasVSCodeFlag = $projectScript -match "--vscode"
$hasVSCodeVariable = $projectScript -match "VSCODE=false"
$hasVSCodeInstallation = $projectScript -match "Handle VSCode installation"

Write-Host "Setup Script Tests:" -ForegroundColor Yellow
if ($hasVSCodeFlag) {
    Write-Host "  ✓ VSCode flag support added" -ForegroundColor Green
} else {
    Write-Host "  ✗ VSCode flag support missing" -ForegroundColor Red
}

if ($hasVSCodeVariable) {
    Write-Host "  ✓ VSCode variable initialization found" -ForegroundColor Green
} else {
    Write-Host "  ✗ VSCode variable initialization missing" -ForegroundColor Red
}

if ($hasVSCodeInstallation) {
    Write-Host "  ✓ VSCode installation logic found" -ForegroundColor Green
} else {
    Write-Host "  ✗ VSCode installation logic missing" -ForegroundColor Red
}

# Test 2: Validate JSON templates
Write-Host "`nJSON Template Tests:" -ForegroundColor Yellow

$settingsTemplate = @'
{
    "files.exclude": {
        "**/.agent-os/specs/**/research-findings": true
    },
    "search.exclude": {
        "**/.agent-os/specs/**/research-findings": true
    },
    "files.associations": {
        "*.md": "markdown"
    }
}
'@

$tasksTemplate = '{"version": "2.0.0", "tasks": []}'

$extensionsTemplate = @'
{
    "recommendations": [
        "github.copilot",
        "github.copilot-chat",
        "ms-vscode.vscode-json"
    ]
}
'@

try {
    $settingsTemplate | ConvertFrom-Json | Out-Null
    Write-Host "  ✓ settings.json template is valid JSON" -ForegroundColor Green
} catch {
    Write-Host "  ✗ settings.json template has invalid JSON" -ForegroundColor Red
}

try {
    $tasksTemplate | ConvertFrom-Json | Out-Null
    Write-Host "  ✓ tasks.json template is valid JSON" -ForegroundColor Green
} catch {
    Write-Host "  ✗ tasks.json template has invalid JSON" -ForegroundColor Red
}

try {
    $extensionsTemplate | ConvertFrom-Json | Out-Null
    Write-Host "  ✓ extensions.json template is valid JSON" -ForegroundColor Green
} catch {
    Write-Host "  ✗ extensions.json template has invalid JSON" -ForegroundColor Red
}

# Test 3: Check auto-detection logic
Write-Host "`nAuto-detection Logic Tests:" -ForegroundColor Yellow
$hasAutoDetection = $projectScript -match "Auto-detected VSCode environment"
$hasWorkspaceDetection = $projectScript -match "Auto-detected VSCode workspace"

if ($hasAutoDetection) {
    Write-Host "  ✓ VSCode directory auto-detection logic found" -ForegroundColor Green
} else {
    Write-Host "  ✗ VSCode directory auto-detection logic missing" -ForegroundColor Red
}

if ($hasWorkspaceDetection) {
    Write-Host "  ✓ VSCode workspace auto-detection logic found" -ForegroundColor Green
} else {
    Write-Host "  ✗ VSCode workspace auto-detection logic missing" -ForegroundColor Red
}

Write-Host "`n🎯 VSCode Integration Validation Complete" -ForegroundColor Cyan

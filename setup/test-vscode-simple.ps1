# Simple VSCode detection test

Write-Host "🧪 Testing VSCode Detection" -ForegroundColor Cyan

$testDir = "$env:TEMP\vscode-test-$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Set-Location $testDir

# Test 1: Create .vscode structure
New-Item -ItemType Directory -Path ".vscode" -Force | Out-Null
'{"editor.fontSize": 14}' | Out-File -FilePath ".vscode\settings.json" -Encoding UTF8

if (Test-Path ".vscode\settings.json") {
    Write-Host "✓ VSCode directory creation: PASSED" -ForegroundColor Green
} else {
    Write-Host "✗ VSCode directory creation: FAILED" -ForegroundColor Red
}

# Test 2: JSON validation
try {
    Get-Content ".vscode\settings.json" -Raw | ConvertFrom-Json | Out-Null
    Write-Host "✓ JSON validation: PASSED" -ForegroundColor Green
} catch {
    Write-Host "✗ JSON validation: FAILED" -ForegroundColor Red
}

# Cleanup
Set-Location C:\
Remove-Item $testDir -Recurse -Force

Write-Host "Tests completed" -ForegroundColor Cyan

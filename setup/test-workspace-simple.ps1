# Simple workspace detection test

Write-Host "Testing Workspace Detection" -ForegroundColor Cyan

$testDir = "$env:TEMP\workspace-test-$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Set-Location $testDir

# Create workspace file
'{"folders": [{"path": "."}], "settings": {}}' | Out-File -FilePath "test.code-workspace" -Encoding UTF8

# Test detection
if (Test-Path "test.code-workspace") {
    Write-Host "Workspace file created: PASSED" -ForegroundColor Green
} else {
    Write-Host "Workspace file created: FAILED" -ForegroundColor Red
}

# Test pattern matching
$workspaceFiles = Get-ChildItem "*.code-workspace" -ErrorAction SilentlyContinue
if ($workspaceFiles.Count -gt 0) {
    Write-Host "Workspace pattern detection: PASSED" -ForegroundColor Green
} else {
    Write-Host "Workspace pattern detection: FAILED" -ForegroundColor Red
}

# Cleanup
Set-Location C:\
Remove-Item $testDir -Recurse -Force

Write-Host "Workspace tests completed" -ForegroundColor Cyan

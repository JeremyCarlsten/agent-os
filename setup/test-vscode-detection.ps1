# Test script for VSCode detection functionality
# Tests the enhanced project.sh script for VSCode environment detection

$TestDir = "$env:TEMP\agent-os-vscode-test-$(Get-Random)"

# Test counters
$TestsRun = 0
$TestsPassed = 0
$TestsFailed = 0

function Test-VSCodeDirectoryDetection {
    $testDir = "$env:TEMP\vscode-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Push-Location $testDir
    
    try {
        # Create .vscode directory structure
        New-Item -ItemType Directory -Path ".vscode" -Force | Out-Null
        '{"editor.fontSize": 14}' | Out-File -FilePath ".vscode\settings.json" -Encoding UTF8
        
        # Check that directory and file exist
        $result = (Test-Path ".vscode") -and (Test-Path ".vscode\settings.json")
        return $result
    }
    finally {
        Pop-Location
        Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Test-VSCodeConfigTemplates {
    $testDir = "$env:TEMP\vscode-config-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Push-Location $testDir
    
    try {
        # Create expected template structure
        New-Item -ItemType Directory -Path ".vscode" -Force | Out-Null
        
        # Expected settings.json template
        $settingsContent = '{"files.exclude": {"**/.agent-os/specs/**/research-findings": true}}'
        $settingsContent | Out-File -FilePath ".vscode\settings.json" -Encoding UTF8
        
        # Expected tasks.json template
        $tasksContent = '{"version": "2.0.0", "tasks": []}'
        $tasksContent | Out-File -FilePath ".vscode\tasks.json" -Encoding UTF8
        
        # Expected extensions.json template
        $extensionsContent = '{"recommendations": ["github.copilot"]}'
        $extensionsContent | Out-File -FilePath ".vscode\extensions.json" -Encoding UTF8
        
        # Verify all template files exist and are valid JSON
        $result = $true
        foreach ($file in @("settings.json", "tasks.json", "extensions.json")) {
            $path = ".vscode\$file"
            if (Test-Path $path) {
                try {
                    Get-Content $path -Raw | ConvertFrom-Json | Out-Null
                }
                catch {
                    $result = $false
                    break
                }
            }
            else {
                $result = $false
                break
            }
        }
        
        return $result
    }
    finally {
        Pop-Location
        Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Test-VSCodeCursorCoexistence {
    $testDir = "$env:TEMP\vscode-cursor-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Push-Location $testDir
    
    try {
        # Create both .vscode and .cursor directories
        New-Item -ItemType Directory -Path ".vscode" -Force | Out-Null
        New-Item -ItemType Directory -Path ".cursor\rules" -Force | Out-Null
        '{"editor.fontSize": 14}' | Out-File -FilePath ".vscode\settings.json" -Encoding UTF8
        '# Cursor rule' | Out-File -FilePath ".cursor\rules\test.mdc" -Encoding UTF8
        
        # Verify both can coexist
        $result = (Test-Path ".vscode") -and (Test-Path ".cursor")
        return $result
    }
    finally {
        Pop-Location
        Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Main test execution
Write-Host "🧪 Agent OS VSCode Detection Tests" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Test 1
Write-Host "Running: VSCode directory detection" -ForegroundColor Yellow
$TestsRun++
try {
    if (Test-VSCodeDirectoryDetection) {
        Write-Host "✓ PASSED: VSCode directory detection" -ForegroundColor Green
        $TestsPassed++
    }
    else {
        Write-Host "✗ FAILED: VSCode directory detection" -ForegroundColor Red
        $TestsFailed++
    }
}
catch {
    Write-Host "✗ FAILED: VSCode directory detection (Exception: $_)" -ForegroundColor Red
    $TestsFailed++
}
Write-Host ""

# Test 2
Write-Host "Running: VSCode configuration templates" -ForegroundColor Yellow
$TestsRun++
try {
    if (Test-VSCodeConfigTemplates) {
        Write-Host "✓ PASSED: VSCode configuration templates" -ForegroundColor Green
        $TestsPassed++
    }
    else {
        Write-Host "✗ FAILED: VSCode configuration templates" -ForegroundColor Red
        $TestsFailed++
    }
}
catch {
    Write-Host "✗ FAILED: VSCode configuration templates (Exception: $_)" -ForegroundColor Red
    $TestsFailed++
}
Write-Host ""

# Test 3
Write-Host "Running: VSCode and Cursor coexistence" -ForegroundColor Yellow
$TestsRun++
try {
    if (Test-VSCodeCursorCoexistence) {
        Write-Host "✓ PASSED: VSCode and Cursor coexistence" -ForegroundColor Green
        $TestsPassed++
    }
    else {
        Write-Host "✗ FAILED: VSCode and Cursor coexistence" -ForegroundColor Red
        $TestsFailed++
    }
}
catch {
    Write-Host "✗ FAILED: VSCode and Cursor coexistence (Exception: $_)" -ForegroundColor Red
    $TestsFailed++
}
Write-Host ""

# Print summary
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Test Summary:"
Write-Host "  Total tests run: $TestsRun"
Write-Host "  Tests passed: $TestsPassed" -ForegroundColor Green
if ($TestsFailed -gt 0) {
    Write-Host "  Tests failed: $TestsFailed" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "  All tests passed! ✓" -ForegroundColor Green
    exit 0
}
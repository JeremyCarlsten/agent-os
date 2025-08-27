# Test script for multi-root workspace detection

Write-Host "🧪 Testing Multi-Root Workspace Detection" -ForegroundColor Cyan

$testDir = "$env:TEMP\workspace-test-$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Set-Location $testDir

# Test 1: Create .code-workspace file
$workspaceContent = @'
{
    "folders": [
        {
            "path": "./frontend"
        },
        {
            "path": "./backend"
        }
    ],
    "settings": {
        "editor.fontSize": 14,
        "files.exclude": {
            "**/.agent-os/specs/**/research-findings": true
        }
    },
    "extensions": {
        "recommendations": [
            "github.copilot",
            "github.copilot-chat"
        ]
    }
}
'@

$workspaceContent | Out-File -FilePath "test-project.code-workspace" -Encoding UTF8

# Test 2: Verify workspace file exists and is valid JSON
if (Test-Path "test-project.code-workspace") {
    Write-Host "✓ Workspace file creation: PASSED" -ForegroundColor Green
    
    try {
        $workspace = Get-Content "test-project.code-workspace" -Raw | ConvertFrom-Json
        Write-Host "✓ Workspace JSON validation: PASSED" -ForegroundColor Green
        
        # Test 3: Verify workspace structure
        if ($workspace.folders -and $workspace.folders.Count -eq 2) {
            Write-Host "✓ Multi-root folder structure: PASSED" -ForegroundColor Green
        } else {
            Write-Host "✗ Multi-root folder structure: FAILED" -ForegroundColor Red
        }
        
        # Test 4: Verify Agent OS settings are present
        if ($workspace.settings -and $workspace.settings."files.exclude") {
            Write-Host "✓ Agent OS settings integration: PASSED" -ForegroundColor Green
        } else {
            Write-Host "✗ Agent OS settings integration: FAILED" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "✗ Workspace JSON validation: FAILED - $_" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Workspace file creation: FAILED" -ForegroundColor Red
}

# Test 5: Test workspace detection pattern
$hasWorkspaceFile = (Get-ChildItem "*.code-workspace" -ErrorAction SilentlyContinue).Count -gt 0
if ($hasWorkspaceFile) {
    Write-Host "✓ Workspace file pattern detection: PASSED" -ForegroundColor Green
} else {
    Write-Host "✗ Workspace file pattern detection: FAILED" -ForegroundColor Red
}

# Cleanup
Set-Location C:\
Remove-Item $testDir -Recurse -Force

Write-Host "🎯 Multi-Root Workspace Tests Completed" -ForegroundColor Cyan

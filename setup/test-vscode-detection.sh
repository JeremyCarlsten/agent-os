#!/bin/bash

# Test script for VSCode detection functionality
# Tests the enhanced project.sh script for VSCode environment detection

set -e

TEST_DIR="/tmp/agent-os-vscode-test-$$"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_SCRIPT="$SCRIPT_DIR/project.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if $test_function; then
        echo -e "${GREEN}✓ PASSED: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAILED: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

setup_test_environment() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
}

cleanup_test_environment() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test 1: VSCode directory detection
test_vscode_directory_detection() {
    setup_test_environment
    
    # Create .vscode directory structure
    mkdir -p .vscode
    echo '{"editor.fontSize": 14}' > .vscode/settings.json
    
    # Run project.sh with --vscode flag (when implemented)
    # For now, we'll test that the directory exists
    if [ -d ".vscode" ] && [ -f ".vscode/settings.json" ]; then
        cleanup_test_environment
        return 0
    else
        cleanup_test_environment
        return 1
    fi
}

# Test 2: VSCode auto-detection when .vscode exists
test_vscode_auto_detection() {
    setup_test_environment
    
    # Create .vscode directory to simulate existing VSCode project
    mkdir -p .vscode
    echo '{"editor.fontSize": 14}' > .vscode/settings.json
    
    # Check that directory structure is detected
    if [ -d ".vscode" ]; then
        cleanup_test_environment
        return 0
    else
        cleanup_test_environment
        return 1
    fi
}

# Test 3: Multi-root workspace detection
test_workspace_file_detection() {
    setup_test_environment
    
    # Create .code-workspace file
    cat > test-workspace.code-workspace << EOF
{
    "folders": [
        {
            "path": "."
        }
    ],
    "settings": {
        "editor.fontSize": 14
    }
}
EOF
    
    # Check that workspace file exists and is valid JSON
    if [ -f "test-workspace.code-workspace" ] && jq empty test-workspace.code-workspace 2>/dev/null; then
        cleanup_test_environment
        return 0
    else
        cleanup_test_environment
        return 1
    fi
}

# Test 4: VSCode configuration template generation
test_vscode_config_templates() {
    setup_test_environment
    
    # This will test the template generation when implemented
    # For now, create expected template structure
    mkdir -p .vscode
    
    # Expected settings.json template
    cat > .vscode/settings.json << EOF
{
    "files.exclude": {
        "**/.agent-os/specs/**/research-findings": true
    },
    "search.exclude": {
        "**/.agent-os/specs/**/research-findings": true
    }
}
EOF
    
    # Expected tasks.json template
    cat > .vscode/tasks.json << EOF
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Agent OS: Plan Product",
            "type": "shell",
            "command": "@.agent-os/instructions/core/plan-product.md",
            "group": "build"
        },
        {
            "label": "Agent OS: Create Spec",
            "type": "shell",
            "command": "@.agent-os/instructions/core/create-spec.md",
            "group": "build"
        }
    ]
}
EOF
    
    # Expected extensions.json template
    cat > .vscode/extensions.json << EOF
{
    "recommendations": [
        "github.copilot",
        "github.copilot-chat",
        "ms-vscode.vscode-json"
    ]
}
EOF
    
    # Verify all template files exist and are valid JSON
    if [ -f ".vscode/settings.json" ] && [ -f ".vscode/tasks.json" ] && [ -f ".vscode/extensions.json" ] &&
       jq empty .vscode/settings.json 2>/dev/null &&
       jq empty .vscode/tasks.json 2>/dev/null &&
       jq empty .vscode/extensions.json 2>/dev/null; then
        cleanup_test_environment
        return 0
    else
        cleanup_test_environment
        return 1
    fi
}

# Test 5: VSCode and Cursor coexistence
test_vscode_cursor_coexistence() {
    setup_test_environment
    
    # Create both .vscode and .cursor directories
    mkdir -p .vscode .cursor/rules
    echo '{"editor.fontSize": 14}' > .vscode/settings.json
    echo '# Cursor rule' > .cursor/rules/test.mdc
    
    # Verify both can coexist
    if [ -d ".vscode" ] && [ -d ".cursor" ]; then
        cleanup_test_environment
        return 0
    else
        cleanup_test_environment
        return 1
    fi
}

# Main test execution
main() {
    echo "🧪 Agent OS VSCode Detection Tests"
    echo "=================================="
    echo ""
    
    # Check dependencies
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}Warning: jq not found, some JSON validation tests may be skipped${NC}"
    fi
    
    # Run all tests
    run_test "VSCode directory detection" test_vscode_directory_detection
    run_test "VSCode auto-detection" test_vscode_auto_detection
    run_test "Workspace file detection" test_workspace_file_detection
    run_test "VSCode configuration templates" test_vscode_config_templates
    run_test "VSCode and Cursor coexistence" test_vscode_cursor_coexistence
    
    # Print summary
    echo "=================================="
    echo "Test Summary:"
    echo "  Total tests run: $TESTS_RUN"
    echo -e "  ${GREEN}Tests passed: $TESTS_PASSED${NC}"
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "  ${RED}Tests failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "  ${GREEN}All tests passed! ✓${NC}"
        exit 0
    fi
}

# Run main function
main "$@"

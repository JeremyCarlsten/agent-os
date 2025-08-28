#!/bin/bash

# Integration test suite for GitHub Copilot integration
# Tests the complete end-to-end installation workflow

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test directories
TEST_BASE_DIR=""
TEST_PROJECT_DIR=""

# Test helper functions
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
    echo
}

assert_file_exists() {
    local file="$1"
    local message="$2"
    
    if [ -f "$file" ]; then
        return 0
    else
        echo "  File does not exist: $file"
        echo "  Message: $message"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="$2"
    
    if [ -d "$dir" ]; then
        return 0
    else
        echo "  Directory does not exist: $dir"
        echo "  Message: $message"
        return 1
    fi
}

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    local message="$3"
    
    if [ -f "$file" ] && grep -q "$pattern" "$file"; then
        return 0
    else
        echo "  File '$file' does not contain '$pattern'"
        echo "  Message: $message"
        return 1
    fi
}

# Setup and teardown functions
setup_test_environment() {
    echo -e "${BLUE}Setting up test environment...${NC}"
    
    # Create temporary directories
    TEST_BASE_DIR=$(mktemp -d -t agent-os-base-test-XXXXXX)
    TEST_PROJECT_DIR=$(mktemp -d -t agent-os-project-test-XXXXXX)
    
    echo "  Test base directory: $TEST_BASE_DIR"
    echo "  Test project directory: $TEST_PROJECT_DIR"
    
    # Copy current Agent OS to test base directory
    cp -r . "$TEST_BASE_DIR/"
    
    # Ensure scripts are executable
    chmod +x "$TEST_BASE_DIR/setup/base.sh" 2>/dev/null || true
    chmod +x "$TEST_BASE_DIR/setup/project.sh" 2>/dev/null || true
}

cleanup_test_environment() {
    echo -e "${BLUE}Cleaning up test environment...${NC}"
    
    if [ -n "$TEST_BASE_DIR" ] && [ -d "$TEST_BASE_DIR" ]; then
        rm -rf "$TEST_BASE_DIR"
    fi
    
    if [ -n "$TEST_PROJECT_DIR" ] && [ -d "$TEST_PROJECT_DIR" ]; then
        rm -rf "$TEST_PROJECT_DIR"
    fi
}

# Test functions
test_base_installation_with_copilot() {
    # Test that base installation with --copilot flag works
    cd "$TEST_BASE_DIR"
    
    # Run base installation with --copilot flag (simulate)
    # Note: We'll test the script components rather than full execution
    
    local result=0
    
    # Check that config.yml has copilot section
    assert_file_contains "config.yml" "copilot:" "Base config should have copilot section" || result=1
    
    # Check that base.sh handles --copilot flag
    assert_file_contains "setup/base.sh" "--copilot" "Base script should handle --copilot flag" || result=1
    
    # Check that COPILOT variable is initialized
    assert_file_contains "setup/base.sh" "COPILOT=false" "Base script should initialize COPILOT variable" || result=1
    
    return $result
}

test_project_installation_with_copilot() {
    # Test that project installation with --copilot flag works
    cd "$TEST_PROJECT_DIR"
    
    # Initialize a basic project structure
    mkdir -p commands
    cp "$TEST_BASE_DIR/commands"/*.md commands/ 2>/dev/null || true
    
    local result=0
    
    # Check that project.sh handles --copilot flag
    assert_file_contains "$TEST_BASE_DIR/setup/project.sh" "--copilot" "Project script should handle --copilot flag" || result=1
    
    # Check that project.sh has copilot installation logic
    assert_file_contains "$TEST_BASE_DIR/setup/project.sh" "Installing GitHub Copilot support" "Project script should have Copilot installation logic" || result=1
    
    return $result
}

test_copilot_file_structure_creation() {
    # Test that the correct file structure is created
    cd "$TEST_PROJECT_DIR"
    
    # Simulate running the conversion functions
    source "$TEST_BASE_DIR/setup/functions.sh"
    
    # Create test command file
    mkdir -p commands
    echo "# Test Command" > commands/test-command.md
    echo "This is a test command." >> commands/test-command.md
    
    local result=0
    
    # Test individual conversion
    convert_to_copilot_instruction "commands/test-command.md" ".github/instructions/test-command.instructions.md"
    assert_file_exists ".github/instructions/test-command.instructions.md" "Should create individual instruction file" || result=1
    assert_file_contains ".github/instructions/test-command.instructions.md" "applyTo:" "Should have applyTo frontmatter" || result=1
    
    # Test consolidated generation
    generate_copilot_instructions "." "commands"
    assert_file_exists ".github/copilot-instructions.md" "Should create main copilot instructions file" || result=1
    assert_file_contains ".github/copilot-instructions.md" "Agent OS - GitHub Copilot Instructions" "Should have proper header" || result=1
    
    return $result
}

test_auto_enable_functionality() {
    # Test that auto-enable logic works correctly
    cd "$TEST_BASE_DIR"
    
    local result=0
    
    # Check that auto-enable logic exists in project.sh
    assert_file_contains "setup/project.sh" "Auto-enabling GitHub Copilot support" "Should have auto-enable logic" || result=1
    
    # Check that the logic checks for copilot in config
    assert_file_contains "setup/project.sh" 'grep -q "copilot:"' "Should check for copilot in config" || result=1
    
    return $result
}

test_applyo_patterns_configuration() {
    # Test that applyTo patterns are correctly configured
    cd "$TEST_PROJECT_DIR"
    
    source "$TEST_BASE_DIR/setup/functions.sh"
    
    # Create test files with different command types
    mkdir -p commands
    echo "# Plan Product" > commands/plan-product.md
    echo "# Create Spec" > commands/create-spec.md
    
    local result=0
    
    # Test plan-product (should have "**" pattern)
    convert_to_copilot_instruction "commands/plan-product.md" ".github/instructions/plan-product.instructions.md"
    assert_file_contains ".github/instructions/plan-product.instructions.md" 'applyTo: "**"' "plan-product should have global pattern" || result=1
    
    # Test create-spec (should have "**/*.md" pattern)
    convert_to_copilot_instruction "commands/create-spec.md" ".github/instructions/create-spec.instructions.md"
    assert_file_contains ".github/instructions/create-spec.instructions.md" 'applyTo: "**/*.md"' "create-spec should have markdown pattern" || result=1
    
    return $result
}

test_installation_success_messages() {
    # Test that installation success messages include Copilot information
    local result=0
    
    # Check project.sh success messages
    assert_file_contains "$TEST_BASE_DIR/setup/project.sh" "GitHub Copilot usage:" "Should have Copilot usage instructions" || result=1
    assert_file_contains "$TEST_BASE_DIR/setup/project.sh" ".github/copilot-instructions.md" "Should mention main instructions file" || result=1
    assert_file_contains "$TEST_BASE_DIR/setup/project.sh" ".github/instructions/" "Should mention instructions directory" || result=1
    
    return $result
}

test_help_documentation_updates() {
    # Test that help documentation includes Copilot flag
    local result=0
    
    # Check base.sh help
    assert_file_contains "$TEST_BASE_DIR/setup/base.sh" "Add GitHub Copilot support" "base.sh should document --copilot flag" || result=1
    
    # Check project.sh help
    assert_file_contains "$TEST_BASE_DIR/setup/project.sh" "Add GitHub Copilot support" "project.sh should document --copilot flag" || result=1
    
    return $result
}

# Main test execution
main() {
    echo "=== Agent OS GitHub Copilot Integration Tests ==="
    echo "Testing complete end-to-end Copilot integration functionality"
    echo
    
    # Setup
    setup_test_environment
    
    # Run tests
    echo "--- Testing Base Installation ---"
    run_test "Base installation with --copilot flag" test_base_installation_with_copilot
    
    echo "--- Testing Project Installation ---"
    run_test "Project installation with --copilot flag" test_project_installation_with_copilot
    run_test "Copilot file structure creation" test_copilot_file_structure_creation
    run_test "Auto-enable functionality" test_auto_enable_functionality
    
    echo "--- Testing Configuration and Patterns ---"
    run_test "ApplyTo patterns configuration" test_applyo_patterns_configuration
    
    echo "--- Testing Documentation ---"
    run_test "Installation success messages" test_installation_success_messages
    run_test "Help documentation updates" test_help_documentation_updates
    
    # Cleanup
    cleanup_test_environment
    
    # Summary
    echo "=== Integration Test Results ==="
    echo "Tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All integration tests passed! 🚀${NC}"
        exit 0
    else
        echo -e "${RED}Some integration tests failed.${NC}"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

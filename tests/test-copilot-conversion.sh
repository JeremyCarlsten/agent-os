#!/bin/bash

# Test suite for Copilot file conversion functions
# Tests for convert_to_copilot_instruction() and related functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

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

# Setup and teardown
setup_test_environment() {
    # Create temporary directory for testing
    TEST_DIR=$(mktemp -d)
    mkdir -p "$TEST_DIR/.github/instructions"
    
    # Create test command file
    cat > "$TEST_DIR/test-command.md" << 'EOF'
# Test Command

This is a test command for Agent OS.

## Usage

Use this command to test functionality.

## Example

```bash
./test-command.sh
```
EOF
}

cleanup_test_environment() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

# Test functions for convert_to_copilot_instruction function
test_convert_to_copilot_instruction_function_exists() {
    # Source functions.sh and check if convert_to_copilot_instruction exists
    source setup/functions.sh
    
    if declare -f convert_to_copilot_instruction > /dev/null; then
        return 0
    else
        echo "  convert_to_copilot_instruction function not found"
        return 1
    fi
}

test_convert_to_copilot_instruction_creates_file() {
    setup_test_environment
    source setup/functions.sh
    
    # Test that function creates output file
    convert_to_copilot_instruction "$TEST_DIR/test-command.md" "$TEST_DIR/.github/instructions/test-command.instructions.md"
    
    local result=0
    assert_file_exists "$TEST_DIR/.github/instructions/test-command.instructions.md" "Function should create output file" || result=1
    
    cleanup_test_environment
    return $result
}

test_convert_to_copilot_instruction_adds_frontmatter() {
    setup_test_environment
    source setup/functions.sh
    
    # Test that function adds YAML frontmatter
    convert_to_copilot_instruction "$TEST_DIR/test-command.md" "$TEST_DIR/.github/instructions/test-command.instructions.md"
    
    local result=0
    assert_file_contains "$TEST_DIR/.github/instructions/test-command.instructions.md" "---" "Output should have YAML frontmatter" || result=1
    assert_file_contains "$TEST_DIR/.github/instructions/test-command.instructions.md" "applyTo:" "Output should have applyTo field" || result=1
    
    cleanup_test_environment
    return $result
}

test_copilot_instructions_md_generation() {
    setup_test_environment
    source setup/functions.sh
    
    # Test generation of main copilot-instructions.md file
    # This function should be implemented to consolidate all commands
    if declare -f generate_copilot_instructions > /dev/null; then
        generate_copilot_instructions "$TEST_DIR" "commands/"
        assert_file_exists "$TEST_DIR/.github/copilot-instructions.md" "Should generate main copilot-instructions.md"
    else
        echo "  generate_copilot_instructions function not implemented yet"
        return 1
    fi
    
    cleanup_test_environment
}

test_individual_instructions_files_generation() {
    setup_test_environment
    source setup/functions.sh
    
    # Test generation of individual .instructions.md files
    if declare -f generate_individual_instructions > /dev/null; then
        generate_individual_instructions "$TEST_DIR" "commands/"
        
        local result=0
        assert_file_exists "$TEST_DIR/.github/instructions/plan-product.instructions.md" "Should generate plan-product instructions" || result=1
        assert_file_exists "$TEST_DIR/.github/instructions/create-spec.instructions.md" "Should generate create-spec instructions" || result=1
        
        cleanup_test_environment
        return $result
    else
        echo "  generate_individual_instructions function not implemented yet"
        cleanup_test_environment
        return 1
    fi
}

test_applyo_patterns_configuration() {
    setup_test_environment
    source setup/functions.sh
    
    # Test that applyTo patterns are properly configured
    convert_to_copilot_instruction "$TEST_DIR/test-command.md" "$TEST_DIR/.github/instructions/test-command.instructions.md"
    
    local result=0
    # Check for proper applyTo pattern (should be "**" for general commands)
    assert_file_contains "$TEST_DIR/.github/instructions/test-command.instructions.md" 'applyTo: "**"' "Should have proper applyTo pattern" || result=1
    
    cleanup_test_environment
    return $result
}

# Main test execution
main() {
    echo "=== Agent OS Copilot Conversion Function Tests ==="
    echo "Testing GitHub Copilot file conversion functionality"
    echo

    # Test basic function existence and functionality
    echo "--- Testing convert_to_copilot_instruction function ---"
    run_test "convert_to_copilot_instruction function exists" test_convert_to_copilot_instruction_function_exists
    run_test "convert_to_copilot_instruction creates output file" test_convert_to_copilot_instruction_creates_file
    run_test "convert_to_copilot_instruction adds frontmatter" test_convert_to_copilot_instruction_adds_frontmatter
    run_test "applyTo patterns are configured correctly" test_applyo_patterns_configuration
    
    # Test higher-level generation functions
    echo "--- Testing file generation functions ---"
    run_test "copilot-instructions.md generation" test_copilot_instructions_md_generation
    run_test "individual instructions files generation" test_individual_instructions_files_generation
    
    # Summary
    echo "=== Test Results ==="
    echo "Tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

#!/bin/bash

# Test suite for Agent OS installation scripts
# Tests for GitHub Copilot integration functionality

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

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo "  Expected: '$expected'"
        echo "  Actual: '$actual'"
        echo "  Message: $message"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="$3"
    
    if echo "$haystack" | grep -q "$needle"; then
        return 0
    else
        echo "  Expected '$haystack' to contain '$needle'"
        echo "  Message: $message"
        return 1
    fi
}

# Test functions for base.sh Copilot flag parsing
test_base_sh_copilot_flag_parsing() {
    # Create temporary base.sh for testing
    local temp_base="$(mktemp)"
    cp setup/base.sh "$temp_base"
    
    # Test that --copilot flag is recognized
    local help_output
    help_output=$("$temp_base" --help 2>&1 || true)
    
    assert_contains "$help_output" "--copilot" "Help text should include --copilot flag"
    
    rm "$temp_base"
}

test_base_sh_copilot_flag_sets_variable() {
    # Test that COPILOT variable is set when --copilot flag is used
    # This will be implemented after we add the flag parsing
    local temp_script="$(mktemp)"
    
    cat > "$temp_script" << 'EOF'
#!/bin/bash
source setup/base.sh --copilot --help > /dev/null 2>&1 || true
if [ "$COPILOT" = true ]; then
    echo "COPILOT_SET"
fi
EOF
    
    chmod +x "$temp_script"
    local output
    output=$("$temp_script" 2>/dev/null || true)
    
    # This test will initially fail until we implement the flag
    if [ "$output" = "COPILOT_SET" ]; then
        rm "$temp_script"
        return 0
    else
        rm "$temp_script"
        return 1
    fi
}

# Test functions for project.sh Copilot flag parsing
test_project_sh_copilot_flag_parsing() {
    # Create temporary project.sh for testing
    local temp_project="$(mktemp)"
    cp setup/project.sh "$temp_project"
    
    # Test that --copilot flag is recognized
    local help_output
    help_output=$("$temp_project" --help 2>&1 || true)
    
    assert_contains "$help_output" "--copilot" "Help text should include --copilot flag"
    
    rm "$temp_project"
}

test_project_sh_copilot_flag_sets_variable() {
    # Test that COPILOT variable is set when --copilot flag is used
    local temp_script="$(mktemp)"
    
    cat > "$temp_script" << 'EOF'
#!/bin/bash
source setup/project.sh --copilot --help > /dev/null 2>&1 || true
if [ "$COPILOT" = true ]; then
    echo "COPILOT_SET"
fi
EOF
    
    chmod +x "$temp_script"
    local output
    output=$("$temp_script" 2>/dev/null || true)
    
    # This test will initially fail until we implement the flag
    if [ "$output" = "COPILOT_SET" ]; then
        rm "$temp_script"
        return 0
    else
        rm "$temp_script"
        return 1
    fi
}

# Test functions for config.yml updates
test_config_yml_copilot_section_exists() {
    # Test that config.yml has copilot section after base installation
    local temp_config="$(mktemp)"
    cp config.yml "$temp_config"
    
    local copilot_section
    copilot_section=$(grep -A1 "copilot:" "$temp_config" || true)
    
    assert_contains "$copilot_section" "enabled:" "Config should have copilot section with enabled flag"
    
    rm "$temp_config"
}

test_config_yml_copilot_enable_logic() {
    # Test that --copilot flag enables copilot in config
    # This will be implemented after we add the functionality
    local temp_config="$(mktemp)"
    cp config.yml "$temp_config"
    
    # Simulate the sed command that should enable copilot
    sed -i.bak '/copilot:/,/enabled:/ s/enabled: false/enabled: true/' "$temp_config" 2>/dev/null || true
    
    local enabled_value
    enabled_value=$(grep -A1 "copilot:" "$temp_config" | grep "enabled:" | awk '{print $2}' || true)
    
    assert_equals "true" "$enabled_value" "Copilot should be enabled in config"
    
    rm "$temp_config" "$temp_config.bak" 2>/dev/null || true
}

# Main test execution
main() {
    echo "=== Agent OS Installation Script Tests ==="
    echo "Testing GitHub Copilot integration functionality"
    echo

    # Test base.sh functionality
    echo "--- Testing base.sh Copilot integration ---"
    run_test "base.sh includes --copilot in help" test_base_sh_copilot_flag_parsing
    run_test "base.sh --copilot flag sets COPILOT variable" test_base_sh_copilot_flag_sets_variable
    
    # Test project.sh functionality  
    echo "--- Testing project.sh Copilot integration ---"
    run_test "project.sh includes --copilot in help" test_project_sh_copilot_flag_parsing
    run_test "project.sh --copilot flag sets COPILOT variable" test_project_sh_copilot_flag_sets_variable
    
    # Test config.yml functionality
    echo "--- Testing config.yml Copilot integration ---"
    run_test "config.yml has copilot section" test_config_yml_copilot_section_exists
    run_test "config.yml copilot enable logic works" test_config_yml_copilot_enable_logic
    
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

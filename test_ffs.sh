#!/usr/bin/env zsh
# Comprehensive test suite for the ffs function

# Don't exit on error - we expect some tests to fail
setopt NO_ERR_EXIT
setopt PIPE_FAIL

# Source the ffs function
source ./ffs.zsh

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test helper functions
run_test() {
    local test_name="$1"
    local test_script="$2"
    local should_succeed="$3"  # "success" or "failure"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Test $TESTS_RUN: $test_name ... "

    # Create a temporary test script that sets up history properly
    local temp_script="/tmp/test_script_$$.zsh"
    cat > "$temp_script" <<'SCRIPT_END'
#!/usr/bin/env zsh
setopt NO_ERR_EXIT
# Set up history for interactive mode
HISTFILE=/tmp/zsh_history_$$
HISTSIZE=1000
SAVEHIST=1000
source ./ffs.zsh
SCRIPT_END
    echo "$test_script" >> "$temp_script"

    # Run the test script in a subshell with history enabled
    local output=$(zsh -i "$temp_script" 2>&1)
    local exit_code=$?

    rm -f "$temp_script"

    if [[ "$should_succeed" == "success" ]]; then
        if [[ $exit_code -eq 0 ]]; then
            echo "${GREEN}PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo "${RED}FAILED${NC}"
            echo "  Expected success but got exit code $exit_code"
            echo "  Output: $output"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        if [[ $exit_code -ne 0 ]]; then
            echo "${GREEN}PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo "${RED}FAILED${NC}"
            echo "  Expected failure but succeeded"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    fi
}

run_test_contains() {
    local test_name="$1"
    local test_script="$2"
    local expected_substring="$3"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Test $TESTS_RUN: $test_name ... "

    # Create a temporary test script
    local temp_script="/tmp/test_script_$$.zsh"
    cat > "$temp_script" <<'SCRIPT_END'
#!/usr/bin/env zsh
setopt NO_ERR_EXIT
# Set up history for interactive mode
HISTFILE=/tmp/zsh_history_$$
HISTSIZE=1000
SAVEHIST=1000
source ./ffs.zsh
SCRIPT_END
    echo "$test_script" >> "$temp_script"

    # Run the test script in a subshell with history enabled
    local output=$(zsh -i "$temp_script" 2>&1)

    rm -f "$temp_script"

    if [[ "$output" == *"$expected_substring"* ]]; then
        echo "${GREEN}PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}FAILED${NC}"
        echo "  Expected output to contain: '$expected_substring'"
        echo "  Got: '$output'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Cleanup function
cleanup() {
    setopt NULL_GLOB 2>/dev/null || true
    rm -f /tmp/test_ffs_*.txt 2>/dev/null || true
    rm -f /tmp/test_script_*.zsh 2>/dev/null || true
    rm -f /tmp/zsh_history_* 2>/dev/null || true
}

# Run cleanup on exit
trap cleanup EXIT

echo "================================================"
echo "FFS Function Test Suite"
echo "================================================"
echo ""

# Test 1: Basic ffs invocation after a command
echo "${YELLOW}=== Test Group 1: Basic Functionality ===${NC}"
run_test "Basic ffs invocation" \
'echo "test1" > /tmp/test_ffs_1.txt
ffs' \
"success"

# Test 2: Same-line invocation with semicolon
run_test "Same-line invocation with semicolon" \
'echo "test2" > /tmp/test_ffs_2.txt; ffs' \
"success"

# Test 3: Same-line invocation with semicolon and spaces
run_test "Same-line invocation with spaces" \
'echo "test3" > /tmp/test_ffs_3.txt ; ffs' \
"success"

# Test 4: Recursion guard - check error message after ffs
echo ""
echo "${YELLOW}=== Test Group 2: Recursion Guard ===${NC}"
run_test_contains "Recursion guard for sudo sh -c pattern" \
'echo "test4" > /tmp/test_ffs_4.txt
ffs &>/dev/null || true
ffs' \
"No valid previous command"

# Test 6: Commands with double quotes
echo ""
echo "${YELLOW}=== Test Group 3: Special Characters ===${NC}"
run_test "Command with double quotes" \
'echo "test with quotes" > /tmp/test_ffs_6.txt
ffs' \
"success"

# Test 7: Commands with single quotes
run_test "Command with single quotes" \
"echo 'test with single quotes' > /tmp/test_ffs_7.txt
ffs" \
"success"

# Test 8: Commands with pipes
run_test "Command with pipe" \
'echo "test8" | cat > /tmp/test_ffs_8.txt
ffs' \
"success"

# Test 9: Commands with redirections
run_test "Command with redirection" \
'echo "test9" > /tmp/test_ffs_9.txt
ffs' \
"success"

# Test 10: Commands with ampersands in strings
run_test "Command with ampersand in string" \
'echo "test & more" > /tmp/test_ffs_10.txt
ffs' \
"success"

# Test 11: Multiple commands in previous line (with &&)
echo ""
echo "${YELLOW}=== Test Group 4: Multiple Commands ===${NC}"
run_test "Multiple commands with &&" \
'echo "test11a" > /tmp/test_ffs_11a.txt && echo "test11b" > /tmp/test_ffs_11b.txt
ffs' \
"success"

# Test 12: Multiple commands with semicolon in previous line
run_test "Multiple commands with semicolon" \
'echo "test12a" > /tmp/test_ffs_12a.txt; echo "test12b" > /tmp/test_ffs_12b.txt
ffs' \
"success"

# Test 13: Error message for empty history
echo ""
echo "${YELLOW}=== Test Group 5: Edge Cases ===${NC}"
run_test_contains "Empty history error message" \
'ffs' \
"No valid previous command"

# Test 15: Command with backticks
run_test "Command after backtick usage" \
': `echo test15`
echo "test15" > /tmp/test_ffs_15.txt
ffs' \
"success"

# Test 14: Verify recursion guard catches sudo sh -c pattern
echo ""
echo "${YELLOW}=== Test Group 6: Sudo Invocation ===${NC}"
run_test_contains "Recursion guard catches sudo sh -c" \
'sudo sh -c "echo test"
ffs' \
"No valid previous command"

# Test 15: Same-line with multiple semicolons before ffs
run_test "Multiple semicolons before ffs" \
'echo "test17a" > /tmp/test_ffs_17a.txt; echo "test17b" > /tmp/test_ffs_17b.txt; ffs' \
"success"

# Test 18: Trailing whitespace handling
run_test "Command with trailing whitespace" \
'echo "test18" > /tmp/test_ffs_18.txt
ffs' \
"success"

# Test 19: Leading whitespace handling
run_test "Command with leading whitespace" \
'  echo "test19" > /tmp/test_ffs_19.txt
ffs' \
"success"

# Test 20: Command with environment variables
run_test "Command with environment variable" \
'TEST_VAR="test20" echo $TEST_VAR > /tmp/test_ffs_20.txt
ffs' \
"success"

# Test 21: ffs on same line should not recurse
run_test "Same-line ffs extraction" \
'echo "test21" > /tmp/test_ffs_21.txt; ffs' \
"success"

# Test 19: Verify ffs doesn't run on empty command
run_test_contains "Error on ffs as first command" \
'ffs' \
"No valid previous command"

# Summary
echo ""
echo "================================================"
echo "Test Results Summary"
echo "================================================"
echo "Total Tests: $TESTS_RUN"
echo "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""
    echo "${RED}TEST SUITE FAILED${NC}"
    exit 1
else
    echo "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""
    echo "${GREEN}ALL TESTS PASSED!${NC}"
    exit 0
fi

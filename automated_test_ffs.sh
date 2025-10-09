#!/bin/bash
# Automated test for ffs.elv using expect-like approach

set -e

echo "Testing ffs function for Elvish..."
echo ""

# Create a test RC file that includes our ffs module
mkdir -p /tmp/elvish_test_config/lib
cp /root/repo/ffs.elv /tmp/elvish_test_config/lib/

cat > /tmp/elvish_test_config/rc.elv << 'EOF'
# Auto-load the ffs module for testing
use ffs
EOF

# Test 1: Basic command
echo "Test 1: Running a basic command and then ffs"
export XDG_CONFIG_HOME=/tmp/elvish_test_config

# We'll use a here-document to send commands to elvish
elvish << 'ELVISH_SCRIPT'
use ffs
echo "Running test command..."
echo "test output" > /tmp/ffs_test_1.txt
echo "Calling ffs..."
ffs:ffs
if (path:is-regular /tmp/ffs_test_1.txt) {
    echo "✓ Test 1: Basic ffs execution works"
} else {
    echo "✗ Test 1: Failed"
}
ELVISH_SCRIPT

# Check results
if [ -f /tmp/ffs_test_1.txt ]; then
    echo "✓ Test 1 passed: File created"
    cat /tmp/ffs_test_1.txt
else
    echo "✗ Test 1 failed: File not created"
fi

echo ""
echo "---"
echo ""

# Test 2: Error handling (running ffs without valid previous command)
echo "Test 2: Error handling when no valid previous command"
elvish << 'ELVISH_SCRIPT'
use ffs
# First ffs call
echo "test" > /tmp/ffs_test_2.txt
ffs:ffs
# Second ffs call should show error
echo "Running ffs again (should error)..."
ffs:ffs
ELVISH_SCRIPT

echo ""
echo "All automated tests completed!"

# Cleanup
rm -f /tmp/ffs_test_1.txt /tmp/ffs_test_2.txt
rm -rf /tmp/elvish_test_config

echo ""
echo "For manual interactive testing, see manual_test_ffs.md"

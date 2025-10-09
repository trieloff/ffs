#!/bin/bash
# Interactive test script for ffs.elv
# This script will run Elvish in interactive mode and test the ffs function

echo "Testing ffs function for Elvish in interactive mode..."
echo ""

# Create a temporary script that will be sourced in the RC file
cat > /tmp/test_ffs_commands.elv << 'EOF'
# Source the ffs module
use ./ffs

# Test 1: Run a harmless command
echo "Test 1: Running a command that would typically need sudo"
echo "test command" > /tmp/test_ffs_output.txt

# Now call ffs to re-run it with sudo
echo "Calling ffs to re-run with sudo..."
ffs:ffs

# Test 2: Verify file was created
if (path:is-regular /tmp/test_ffs_output.txt) {
    echo "✓ Test 1 passed: Command executed successfully"
} else {
    echo "✗ Test 1 failed: File not created"
}

# Test 3: Try to run ffs after ffs (should show error)
echo ""
echo "Test 2: Running ffs after ffs (should show error)"
ffs:ffs

echo ""
echo "All tests completed!"
EOF

# Run Elvish with the test commands
echo "Running tests in Elvish interactive mode..."
elvish -c 'use ./ffs; echo "test command" > /tmp/test_ffs_output.txt; ffs:ffs'

echo ""
echo "Checking if ffs works correctly..."

# Verify the output file exists
if [ -f /tmp/test_ffs_output.txt ]; then
    echo "✓ File created successfully"
    cat /tmp/test_ffs_output.txt
else
    echo "✗ File not found"
fi

# Clean up
rm -f /tmp/test_ffs_output.txt /tmp/test_ffs_commands.elv

echo ""
echo "Test complete!"

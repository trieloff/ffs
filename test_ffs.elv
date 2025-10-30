#!/usr/bin/env elvish
# Test script for the ffs function

# Source the ffs function
use ./ffs

echo "Testing ffs function for Elvish..."
echo ""

# Test 1: Basic functionality
echo "Test 1: Simulate running a command that would need sudo"
echo "$ echo 'This would need sudo' > /tmp/test_ffs_output.txt"
echo "This would need sudo" > /tmp/test_ffs_output.txt

echo ""
echo "Now running ffs to execute with sudo:"
echo "$ ffs:ffs"
ffs:ffs

echo ""
echo "---"
echo ""

# Test 2: Verify it doesn't run ffs recursively
echo "Test 2: Try to run ffs after ffs (should fail)"
echo "$ ffs:ffs"
ffs:ffs

echo ""
echo "Test complete!"

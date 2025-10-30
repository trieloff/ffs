#!/usr/bin/env elvish
# Simple test script for ffs

use ./ffs

# Test 1: Basic functionality
echo "Test 1: Running a basic command"
echo "test output" > /tmp/ffs_test_output.txt

echo "Now calling ffs to re-run with sudo..."
ffs:ffs

echo ""
echo "Test complete!"

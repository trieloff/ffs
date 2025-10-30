#!/bin/bash
# Test script for ffs.elv using expect-like behavior

# Check if expect is installed
if ! command -v expect &> /dev/null; then
    echo "Installing expect for testing..."
    sudo apt-get update -qq && sudo apt-get install -y expect > /dev/null 2>&1
fi

# Create an expect script to test ffs
cat > /tmp/test_ffs.exp << 'EOF'
#!/usr/bin/expect -f

set timeout 10
set prompt "~> "

# Start Elvish
spawn elvish

# Wait for prompt
expect -re ".*> "

# Load the ffs module
send "use ./ffs\r"
expect -re ".*> "

# Test 1: Run a simple command
send "echo 'test output' > /tmp/ffs_elvish_test.txt\r"
expect -re ".*> "

# Give it a moment
sleep 0.5

# Call ffs
send "ffs:ffs\r"

# Look for sudo prompt or execution
expect {
    -re "sudo sh -c" {
        send_user "\n✓ Test 1 PASSED: ffs displayed the sudo command\n"
    }
    timeout {
        send_user "\n✗ Test 1 FAILED: Timeout waiting for ffs output\n"
    }
}

# Wait for command to complete
expect -re ".*> " {
    send_user "Command completed\n"
}

# Give it a moment
sleep 0.5

# Test 2: Try running ffs again (should error since last command was ffs)
send "ffs:ffs\r"

expect {
    -re "Error: No valid previous command found" {
        send_user "\n✓ Test 2 PASSED: ffs correctly detected recursive call\n"
    }
    -re "sudo sh -c" {
        send_user "\n✗ Test 2 FAILED: ffs should have shown an error\n"
    }
    timeout {
        send_user "\n✗ Test 2 FAILED: Timeout\n"
    }
}

# Exit
expect -re ".*> "
send "exit\r"

expect eof
EOF

chmod +x /tmp/test_ffs.exp

echo "=== Testing ffs.elv with Expect ==="
echo ""

# Run the expect script
cd /root/repo && /tmp/test_ffs.exp

echo ""
echo "=== Verification ==="

# Check if the test file was created
if [ -f /tmp/ffs_elvish_test.txt ]; then
    echo "✓ File verification: Test file was created"
    echo "  Content: $(cat /tmp/ffs_elvish_test.txt)"
    rm /tmp/ffs_elvish_test.txt
else
    echo "Note: Test file not created (expected if sudo password was required)"
fi

# Clean up
rm -f /tmp/test_ffs.exp

echo ""
echo "=== Test Complete ==="

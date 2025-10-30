#!/bin/bash
# Demo script for ffs.elv
# This script demonstrates how ffs works in an interactive Elvish session

echo "=== ffs.elv Demo ==="
echo ""
echo "This demo shows how the ffs (Friendly Following Sudo) function works in Elvish."
echo ""
echo "To use ffs in your Elvish shell:"
echo "1. Add ffs.elv to your Elvish library path (e.g., ~/.config/elvish/lib/)"
echo "2. Add 'use ffs' to your rc.elv"
echo "3. Use it interactively by running a command, then typing 'ffs:ffs'"
echo ""
echo "Example interactive session:"
echo "  ~> echo 'test' > /tmp/testfile"
echo "  ~> ffs:ffs"
echo "  $ sudo sh -c 'echo 'test' > /tmp/testfile'"
echo "  [runs the command with sudo]"
echo ""
echo "Starting an interactive Elvish session for you to try..."
echo "Type 'use ./ffs' to load the module, then try the example above."
echo "Type 'exit' when done."
echo ""

# Start an interactive Elvish shell
elvish

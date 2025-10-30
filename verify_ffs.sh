#!/bin/bash
# Quick verification that ffs.elv works correctly

echo "=== Verifying ffs.elv Implementation ==="
echo ""

# Test 1: Check syntax
echo "1. Checking Elvish syntax..."
if elvish -compileonly /root/repo/ffs.elv 2>/dev/null; then
    echo "   ✓ Syntax valid"
else
    echo "   ✗ Syntax error"
    exit 1
fi

# Test 2: Check module loads
echo "2. Checking module can be loaded..."
if elvish -c 'use ./ffs' 2>&1 | grep -q "Error"; then
    echo "   ✗ Module failed to load"
    exit 1
else
    echo "   ✓ Module loads successfully"
fi

# Test 3: Check function exists
echo "3. Checking ffs function exists..."
if elvish -c 'use ./ffs; echo $ffs:ffs~' 2>&1 | grep -q "\[^fn"; then
    echo "   ✓ Function defined"
else
    echo "   ✗ Function not found"
    exit 1
fi

echo ""
echo "=== Basic Validation Complete ==="
echo ""
echo "All checks passed! ffs.elv is ready for interactive use."
echo ""
echo "To test interactively:"
echo "  1. Start Elvish: elvish"
echo "  2. Load the module: use ./ffs"
echo "  3. Run a command: echo 'test' > /tmp/test.txt"
echo "  4. Re-run with sudo: ffs:ffs"
echo ""

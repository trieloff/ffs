# Manual Test Instructions for ffs.elv

To test the ffs function for Elvish, follow these steps in an interactive Elvish shell:

## Setup

1. Start an Elvish shell:
   ```bash
   elvish
   ```

2. Source the ffs module:
   ```elvish
   use ./ffs
   ```

## Test 1: Basic Functionality

Run a harmless command:
```elvish
echo "test command" > /tmp/test_ffs_output.txt
```

Then run ffs to execute it with sudo:
```elvish
ffs:ffs
```

Expected output: You should see the command being re-run with sudo.

## Test 2: Same Line Execution

Try running a command followed by ffs on the same line:
```elvish
echo "same line test" > /tmp/test_ffs_output2.txt; ffs:ffs
```

Expected output: The command before `; ffs:ffs` should be executed with sudo.

## Test 3: Error Handling

Try running ffs without a previous command (or after another ffs):
```elvish
ffs:ffs
```

Expected output: "Error: No valid previous command found"

## Cleanup

```elvish
rm /tmp/test_ffs_output.txt /tmp/test_ffs_output2.txt
```

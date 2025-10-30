#!/usr/bin/env elvish
# ffs - "Friendly Following Sudo" - Execute the previous command with sudo
# Usage:
#   $ rm /etc/somefile
#   Permission denied
#   $ ffs
# Or on the same line:
#   $ rm /etc/somefile; ffs

use str

fn ffs {
    # Get command history (newest first)
    var history = [(edit:command-history &cmd-only &newest-first | all)]

    # Check if we have at least 1 command in history
    if (< (count $history) 1) {
        echo "Error: No valid previous command found"
        return
    }

    # Check if the most recent history entry (index 0) ends with "; ffs" or ";ffs"
    # If so, this means ffs was called as part of a one-liner (e.g., "command; ffs")
    # In that case, do nothing - let the after-command hook handle it
    var current-cmd = $history[0]
    set current-cmd = (str:trim-space $current-cmd)
    if (or (str:has-suffix $current-cmd "; ffs") (str:has-suffix $current-cmd ";ffs")) {
        # This is a one-liner invocation, the hook will handle it
        return
    }

    # Check if we have at least 2 commands in history for standalone usage
    if (< (count $history) 2) {
        echo "Error: No valid previous command found"
        return
    }

    # The first command (index 0) is the current 'ffs' command
    # The second command (index 1) is the one we want to run with sudo
    var command-to-sudo = $history[1]

    # Trim leading and trailing whitespace
    set command-to-sudo = (str:trim-space $command-to-sudo)

    # Check if we got a valid command
    if (or (eq $command-to-sudo "") (eq $command-to-sudo "ffs") (str:has-prefix $command-to-sudo "ffs:ffs")) {
        echo "Error: No valid previous command found"
        return
    }

    # Display the command we're about to execute
    echo "$ sudo sh -c '"$command-to-sudo"'"

    # Execute the command with sudo
    e:sudo sh -c $command-to-sudo
}

# Hook for handling same-line "; ffs" syntax
# This catches failed commands ending with "; ffs" and re-runs them with sudo
fn -after-command-hook {|m|
    # Only process if the command failed (error is not nil)
    if (not-eq $m[error] $nil) {
        # Get the source code that was executed
        var src-code = $m[src][code]
        set src-code = (str:trim-space $src-code)

        # Check if the command ends with "; ffs" or ";ffs"
        if (or (str:has-suffix $src-code "; ffs") (str:has-suffix $src-code ";ffs")) {
            # Extract the command before "; ffs"
            var command-to-sudo = $src-code

            # Remove the trailing "; ffs" or ";ffs"
            if (str:has-suffix $command-to-sudo "; ffs") {
                set command-to-sudo = (str:trim-suffix $command-to-sudo "; ffs")
            } else {
                set command-to-sudo = (str:trim-suffix $command-to-sudo ";ffs")
            }

            set command-to-sudo = (str:trim-space $command-to-sudo)

            # Only proceed if we have a valid command
            if (not-eq $command-to-sudo "") {
                # Display the command we're about to execute
                echo ""
                echo (styled "ffs: Re-running with sudo..." yellow)
                echo "$ sudo sh -c '"$command-to-sudo"'"

                # Execute the command with sudo and catch any errors
                try {
                    e:sudo sh -c $command-to-sudo
                    echo (styled "✓ Command completed successfully" green)
                } catch e {
                    echo (styled "✗ sudo command failed" red)
                }
            }
        }
    }
}

# Install the hook when the module is loaded
set edit:after-command = [$@edit:after-command $-after-command-hook~]

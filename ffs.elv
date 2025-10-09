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

    # Check if we have at least 2 commands in history
    if (< (count $history) 2) {
        echo "Error: No valid previous command found"
        return
    }

    # The first command (index 0) is the current 'ffs' command
    # The second command (index 1) is the one we want to run with sudo
    var command-to-sudo = $history[1]

    # Trim leading and trailing whitespace
    set command-to-sudo = (str:trim-space $command-to-sudo)

    # Check if current command line contains "; ffs" (same line execution)
    # In this case, we need to extract the part before "; ffs"
    if (str:contains $command-to-sudo "; ffs") {
        # Extract everything before "; ffs"
        var parts = (str:split "; ffs" $command-to-sudo)
        set command-to-sudo = $parts[0]
        set command-to-sudo = (str:trim-space $command-to-sudo)
    }

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

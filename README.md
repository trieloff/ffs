# ffs
Friendly, following sudo. What did you think ffs means?

A utility that re-runs your previous command with `sudo`. Available for both **Zsh** and **Elvish** shells.

## Features

- Re-execute the previous command with sudo privileges
- Works when you forgot to add `sudo` before a command
- Simple and intuitive to use
- No more retyping long commands!

## Installation

### Zsh

1. Download the `ffs.zsh` file
2. Source it in your `.zshrc`:
   ```bash
   source /path/to/ffs.zsh
   ```
3. Reload your shell or run `source ~/.zshrc`

### Elvish

1. Copy `ffs.elv` to your Elvish library directory:
   ```bash
   mkdir -p ~/.config/elvish/lib
   cp ffs.elv ~/.config/elvish/lib/
   ```
2. Add to your `~/.config/elvish/rc.elv`:
   ```elvish
   use ffs

   # Optional: Make ffs callable without the namespace prefix
   fn ffs { ffs:ffs }
   ```
3. Restart your Elvish shell

## Usage

### Basic Usage

Run a command that fails due to permissions:
```bash
$ rm /etc/somefile
Permission denied
```

Then run `ffs` to re-execute with sudo:

**Zsh:**
```bash
$ ffs
```

**Elvish:**
```elvish
$ ffs:ffs
# Or just 'ffs' if you added the wrapper function to rc.elv
$ ffs
```

### Same-line Usage

You can also append `ffs` on the same line with a semicolon:

**Zsh:**
```bash
$ rm /etc/somefile; ffs
```

**Elvish:**
```elvish
$ rm /etc/somefile; ffs
```

**Note for Elvish users:** The same-line syntax only triggers on **failed commands**. If your command succeeds, `ffs` does nothing. You'll see the original exception message followed by a success indicator when the sudo retry works.

## How It Works

### Zsh Version
- Uses the `fc` command to access shell history
- Detects if `ffs` was called on the same line and extracts the correct command
- Executes the previous command with `sudo sh -c`

### Elvish Version
The Elvish implementation uses a dual approach to handle its exception-based execution model:

1. **Standalone usage** (`ffs` on its own line):
   - Uses `edit:command-history` API to retrieve the previous command
   - Re-executes it with `sudo sh -c`

2. **Same-line usage** (`command; ffs`):
   - Installs an `$edit:after-command` hook that monitors command execution
   - When a command fails and ends with `;ffs`, the hook intercepts it
   - Extracts the command before `;ffs` and re-runs it with sudo
   - Note: You'll see the original exception (Elvish displays this before the hook runs), followed by the sudo retry and a success/failure indicator

## Testing

### Zsh
```bash
./test_ffs.sh
```

### Elvish
```bash
./verify_ffs.sh
```

For manual testing with Elvish, see `manual_test_ffs.md` or run the demo:
```bash
./demo_ffs.sh
```

## Requirements

- **Zsh**: Zsh shell (typically pre-installed on macOS and most Linux distributions)
- **Elvish**: Elvish shell 0.20.1 or later
  - Install on Ubuntu/Debian: `sudo apt install elvish`
  - See [elvish.sh](https://elv.sh) for other platforms

## License

See LICENSE file for details.

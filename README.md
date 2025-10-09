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
```

### Same-line Usage

You can also append `ffs` on the same line with a semicolon:

**Zsh:**
```bash
$ rm /etc/somefile; ffs
```

**Elvish:**
```elvish
$ rm /etc/somefile; ffs:ffs
```

## How It Works

- **Zsh version**: Uses the `fc` command to access shell history
- **Elvish version**: Uses the `edit:command-history` API to retrieve previous commands
- Both versions detect if `ffs` was called on the same line and extract the correct command
- The previous command is then executed with `sudo sh -c`

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

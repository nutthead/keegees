# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**keegees** is a comprehensive command-line tool for managing GNOME desktop keybindings with beautiful
terminal interfaces, safety mechanisms, and schema-based organization.

## Directory Structure

```
. keegees
├── .claude/
│   └── settings.local.json
├── .markdownlint.json
├── .shellcheckrc
├── CLAUDE.md
├── LICENSE
├── README.md
├── docs/
│   └── assets/
│       └── keegees.webp
├── install.sh
├── keegees.sh
└── samoyed.toml
```

## Project Architecture

### Core Script: keegees.sh

The main executable (1889+ lines of bash) implements:

- **Schema-based keybinding detection** using hardcoded whitelists
- **Dual data source architecture**: INI files + live gsettings/dconf
- **POSIX-compliant arithmetic** using 'bc' instead of bash $((...))
- **Progressive terminal capability detection** (24-bit → 8-bit colors)
- **Extension-aware filtering** for popular GNOME extensions

### Commands

- `ls` - List current system keybindings
- `dump` - Export keybindings to dconf format
- `sync` - Import keybindings from dconf format
- `add` - Interactive keybinding addition
- `reset` - Reset keybindings to defaults
- `del` - Delete specific keybindings
- `help` - Show help information

### Key Design Decisions

1. **Schema Whitelisting**: Explicit hardcoded schema list prevents false positives
2. **Ubuntu Tiling Assistant Filtering**: Special case handling for extension with 87 settings but only 12 keybindings
3. **POSIX Compliance**: Uses 'bc' for arithmetic to ensure cross-shell compatibility
4. **Terminal Capability Detection**: Progressive fallback for color and Unicode support

## Development Commands

### Testing the Script

```bash
# Test with dry-run mode
./keegees.sh ls --dry-run

# Test specific commands
./keegees.sh dump test-backup.dconf --dry-run
./keegees.sh reset --dry-run
```

### Installation

```bash
# Install to ~/.local/bin/keegees
./install.sh

# Install as symlink for development
./install.sh --symlink

# Force overwrite existing installation
./install.sh --force
```

### Code Quality

```bash
# Run ShellCheck (uses .shellcheckrc configuration)
shellcheck keegees.sh install.sh

# Test POSIX compliance
sh -n keegees.sh
```

## Architecture Notes

### Schema Management

The script maintains three synchronized schema whitelists:

- `query_system_settings()` (lines ~338-344)
- `cmd_dump()` (lines ~618-624)  
- `cmd_reset()` (lines ~1297-1303)

When adding new schemas, update all three locations.

### Error Handling

- Uses `set -euo pipefail` for strict error handling
- Comprehensive validation at function entry points
- Graceful degradation for missing dependencies
- Interactive confirmations for destructive operations
- Atomic operations using temporary files

### Animation & UI

- Uses 'bc' for frame calculations (POSIX compliance)
- Progressive terminal capability detection
- 24-bit color support with graceful fallback
- Unicode animations with ASCII alternatives

## Dependencies

- **bash** - Script execution
- **gsettings** - System keybinding queries
- **dconf** - Bulk operations and dumps
- **bc** - POSIX-compliant arithmetic

## Installation Standard

The `install.sh` script:

1. Copies or symlinks `keegees.sh` to `~/.local/bin/keegees`
2. Makes the file executable
3. Checks dependencies and provides installation instructions
4. Verifies installation by running help command

## Common Development Tasks

### Adding New Extension Support

1. Analyze the extension's schema structure
2. Identify actual keybinding keys vs configuration settings
3. Add schema to the three whitelist locations
4. Add special filtering logic if needed (like Ubuntu Tiling Assistant)

### Updating Schema Lists

When GNOME introduces new keybinding schemas:

1. Update whitelists in `query_system_settings()`, `cmd_dump()`, and `cmd_reset()`
2. Test with `--dry-run` mode on all affected commands
3. Verify no false positives are introduced

### Debugging Terminal Issues

- Check `$COLORTERM`, `$TERM` detection logic
- Verify `tput colors` accuracy across terminal emulators
- Test Unicode support detection
- Ensure 'bc' availability for frame calculations

## Testing Workflow

```bash
# Test in a clean environment
docker run -it --rm ubuntu:latest bash
apt update && apt install -y glib2.0-dev bc bash

# Copy and test the script
# Verify it handles missing gsettings gracefully
# Test terminal capability detection
```

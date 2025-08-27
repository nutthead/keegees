#!/usr/bin/env sh
# install.sh — Install the keegees CLI into ~/.local/bin
# Installs the GNOME keybinding management tool into $HOME/.local/bin named `keegees`.
# By default it copies the shell script; you can instead symlink via --symlink.

set -eu

BIN_NAME="keegees"
INSTALL_DIR="${HOME}/.local/bin"
MODE="copy"         # or "symlink"
FORCE=0             # if 1, overwrite existing target
DRYRUN=0            # if 1, print actions only
QUIET=0             # if 1, minimal output

script_dir() {
  # Resolve this script's directory (absolute)
  # shellcheck disable=SC2312,SC1007
  CDPATH= cd -- "$(dirname -- "$0")" && pwd -P
}

log() {
  [ "$QUIET" -eq 1 ] && return 0
  printf '%s\n' "$*"
}

run() {
  if [ "$DRYRUN" -eq 1 ]; then
    printf '[dry-run] %s\n' "$*"
  else
    # shellcheck disable=SC2086
    sh -c "$*"
  fi
}

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Options:
  -s, --symlink       Install as a symlink instead of copying
  -c, --copy          Install by copying (default)
  -f, --force         Overwrite existing target if present
  -n, --dry-run       Show what would be done, without doing it
  -q, --quiet         Suppress non-essential output
  -h, --help          Show this help and exit

Installs:
  ${BIN_NAME} -> ${INSTALL_DIR}/${BIN_NAME}

Source:
  keegees.sh

Requirements:
  - bash (for script execution)
  - gsettings (for system keybinding queries)
  - bc (for POSIX-compliant arithmetic)
EOF
}

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -s|--symlink) MODE="symlink" ;;
    -c|--copy) MODE="copy" ;;
    -f|--force) FORCE=1 ;;
    -n|--dry-run) DRYRUN=1 ;;
    -q|--quiet) QUIET=1 ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

# Resolve paths
SCRIPT_DIR="$(script_dir)"
SOURCE="${SCRIPT_DIR}/keegees.sh"
TARGET="${INSTALL_DIR}/${BIN_NAME}"

# Sanity checks
if [ ! -f "$SOURCE" ]; then
  echo "Error: Source script not found: $SOURCE" >&2
  exit 2
fi

# Ensure install dir
if [ ! -d "$INSTALL_DIR" ]; then
  log "Creating install dir: $INSTALL_DIR"
  run "mkdir -p \"$INSTALL_DIR\""
fi

# Install
if [ "$MODE" = "symlink" ]; then
  log "Installing symlink: $TARGET -> $SOURCE"
  if [ -e "$TARGET" ] && [ "$FORCE" -eq 1 ]; then
    run "rm -f \"$TARGET\""
  fi
  if [ ! -e "$TARGET" ]; then
    run "ln -s \"$SOURCE\" \"$TARGET\""
  else
    log "Target exists: $TARGET (use --force to overwrite)"
  fi
  # Ensure executable bit is not required for symlink; leave as-is.
else
  log "Installing copy to: $TARGET"
  if [ -e "$TARGET" ] && [ "$FORCE" -eq 1 ]; then
    run "rm -f \"$TARGET\""
  fi
  run "cp \"$SOURCE\" \"$TARGET\""
  run "chmod +x \"$TARGET\""
fi

# Check dependencies
if [ "$DRYRUN" -ne 1 ] && [ "$QUIET" -ne 1 ]; then
  log ""
  log "Checking dependencies..."
  
  # Check bash
  if command -v bash >/dev/null 2>&1; then
    log "✓ bash found: $(command -v bash)"
  else
    log "⚠ bash not found - required for script execution"
  fi
  
  # Check gsettings
  if command -v gsettings >/dev/null 2>&1; then
    log "✓ gsettings found: $(command -v gsettings)"
  else
    log "⚠ gsettings not found - required for --system mode"
    log "  Install with: sudo apt install glib2.0-dev (Ubuntu/Debian)"
    log "  Install with: sudo dnf install glib2-devel (Fedora/RHEL)"
  fi
  
  # Check bc
  if command -v bc >/dev/null 2>&1; then
    log "✓ bc found: $(command -v bc)"
  else
    log "⚠ bc not found - required for POSIX arithmetic"
    log "  Install with: sudo apt install bc (Ubuntu/Debian)"
    log "  Install with: sudo dnf install bc (Fedora/RHEL)"
  fi
fi

# PATH notice
case ":$PATH:" in
  *":$INSTALL_DIR:"*) : ;;
  *)
    log ""
    log "Note: $INSTALL_DIR is not in your PATH."
    log "      Add the following to your shell profile (e.g., ~/.bashrc or ~/.zshrc):"
    log "        export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

# Try running version to confirm
if [ "$DRYRUN" -ne 1 ]; then
  if [ -x "$TARGET" ]; then
    log ""
    log "Installed '$BIN_NAME' to: $TARGET"
    if [ "$QUIET" -ne 1 ]; then
      log "Running: $BIN_NAME --help"
      if "$TARGET" --help >/dev/null 2>&1; then
        log "✓ Installation successful! Try: $BIN_NAME ls --help"
      else
        log "(Could not run $BIN_NAME --help. Check dependencies above.)"
      fi
    fi
  else
    echo "Error: Target not executable: $TARGET" >&2
    exit 1
  fi
fi

exit 0
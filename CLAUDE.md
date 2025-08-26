# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**bs.scripts** is a collection of utility scripts organized by programming language. Each script is contained in its
own `<language>/<script-name>/` directory with source code, documentation, and installation tooling.

## Directory Structure

```
. keegees
├── .claude
│   ├── settings2.local.json
│   └── settings.local.json
├── CLAUDE.md
├── .gitignore
├── install.sh
├── keegees
├── .markdownlint.json
├── README.md
├── .ropeproject
└── .shellcheckrc
```

## Current Scripts

### ccmerge (Go)

Claude Code settings merger that discovers and consolidates multiple `.claude/settings.json` and `.claude/settings.local.json`
files using parallel directory traversal and interactive conflict resolution.

**Development Commands:**

```bash
cd go/ccmerge
go run ccmerge.go --search-dirs /path/to/projects --output-json merged.json
go build ccmerge.go  # Creates ccmerge binary
```

**Installation:**

```bash
cd go/ccmerge
./install.sh  # Compiles and installs to $HOME/.local/bin/ccmerge
```

**Usage (after installation):**

```bash
ccmerge --search-dirs /home/user/projects --output-json settings.json
```

**Architecture:** Parallel file discovery using worker pools, type-aware conflict resolution, and interactive user prompts for semantic correctness.

## Development Patterns

### Script Organization

- Each script lives in `<language>/<script-name>/` directory
- Include comprehensive README.md for end users
- Include CLAUDE.md for development guidance specific to that script
- Provide `install.sh` script for compilation and installation to `$HOME/.local/bin/`

### Installation Standard

All scripts follow the `install.sh` pattern:

1. Compile/prepare the script for execution
2. Install to `$HOME/.local/bin/<script-name>`
3. Make executable and available in PATH

### Documentation Hierarchy

- **Repository CLAUDE.md** (this file): High-level structure and navigation
- **Script CLAUDE.md**: Detailed development guidance for specific script
- **README.md**: End-user documentation and usage instructions

## Common Workflows

### Adding New Scripts

1. Create `<language>/<script-name>/` directory
2. Implement script with source code
3. Create `install.sh` for compilation and installation
4. Write README.md for users
5. Write CLAUDE.md for development guidance

### Working with Existing Scripts

1. Navigate to script directory: `cd <language>/<script-name>/`
2. Review script-specific CLAUDE.md for detailed guidance
3. Use development commands for testing/iteration
4. Use `./install.sh` for system installation

### Testing Changes

```workflow testScript
goal: test script **S** and verify its correctness

create(Dockerfile) with {
  - Most appropriate base image
  - Install necessary build dependencies, if not already installed in the base image
  - Write a comprehensive ad-hoc **testingScript** in POSIX sh that creates dirs, files, etc. necessary for testing
    - Copy it to Dockerfile
  - Copy the **S** script to Dockerfile
  - Compile the **S** script, if necessary
  - Build the Dockerfile
  - Run a docker container based on Dockerfile
    - Test the correctness of **S** using **testingScript**
    - Fix **S** if you found a bug in it
  - Stop when **S** passes all the tests
  - Stop the test container
}
```

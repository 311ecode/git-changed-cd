# git-changed-cd (gcd) - Navigate to directories with Git changes

## Overview
`git-changed-cd` (aliased as `gcd`) is a Bash function that helps you quickly navigate to directories containing Git changes in your repository. It detects staged, unstaged, and untracked files, then presents an interactive menu of directories to choose from.

## Usage
```bash
gcd
```

No parameters are required or supported. The command will:
1. Detect your current Git repository
2. Scan for all changes (staged, unstaged, untracked)
3. Present an interactive menu of directories containing changes
4. Change to your selected directory

For help, use:
```bash
gcd -h
# or
gcd --help
```

## Features
- Detects all types of Git changes (staged, unstaged, untracked)
- Shows hierarchical directory structure
- Includes repository root as an option (shown as "<repo root>")
- Handles cancellation gracefully
- Provides clear error messages
- Includes debug mode (set `DEBUG=1` before running)

## How It Works
1. **Change Detection**:
   - Unstaged changes: `git diff --name-only HEAD`
   - Staged changes: `git diff --name-only --cached`
   - Untracked files: `git ls-files --others --exclude-standard`

2. **Directory Processing**:
   - Collects all immediate parent directories of changed files
   - Includes all parent directories up to repository root
   - Presents a sorted, unique list of directories

3. **Navigation**:
   - Uses pushd/popd for reliable directory handling
   - Resolves absolute paths before changing directories
   - Handles edge cases (root directory, missing directories)

## Examples
1. Basic usage:
   ```bash
   $ gcd
   Directories with changes:
   1: <repo root>
   2: src/utils
   3: tests
   Enter the number of the directory to cd into (or 0 to cancel): 2
   Changing directory to: /path/to/repo/src/utils
   ```

2. Debug mode:
   ```bash
   $ DEBUG=1 gcd
   DEBUG[git-changed-cd]: Starting git-changed-cd function
   DEBUG[git-changed-cd]: Getting repository root...
   [...]
   ```

## Error Handling
The command will exit with an error and helpful message if:
- Not in a Git repository
- Failed to navigate to repository root
- No changes detected
- Invalid selection (non-number or out of range)
- Target directory doesn't exist

## Requirements
- Bash shell
- Git installed and in PATH
- Running within a Git repository

## Notes
- The command preserves your original directory if cancelled or on error
- For large repositories with many changes, the menu might be lengthy
- Debug output is sent to stderr and won't interfere with normal operation
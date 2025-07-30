# git-changed-cd (gcd) - Navigate to directories with Git changes

## Overview
`git-changed-cd` (aliased as `gcd`) is a Bash function that helps you quickly navigate to directories containing Git changes in your repository or across multiple registered repositories. It detects staged, unstaged, and untracked files, then presents an interactive menu of directories to choose from.

## Usage

### Basic Navigation
```bash
gcd
```
Navigate within the current Git repository (default behavior).

### Multi-Repository Management
```bash
# Register repositories for multi-repo navigation
git-changed-cd-add-repo /path/to/repo
gcd-add /path/to/repo                    # Short alias

# Remove repositories from registry
git-changed-cd-remove-repo /path/to/repo
gcd-remove /path/to/repo                 # Short alias

# Navigate within registered repositories only
gcd --justRegisteredDirectories
gcdj                                     # Short alias

# Navigate within current + registered repositories
gcd --all
gcda                                     # Short alias
```

### Help
```bash
gcd --help
gcd -h
```

## Features
- **Multi-repository support**: Register and navigate across multiple repositories
- **Flexible scanning modes**: Current repo only, registered repos only, or all combined
- **Change detection**: Staged, unstaged, and untracked files
- **Hierarchical structure**: Shows directory hierarchy with parent directories
- **Sequential numbering**: Consistent numbering across multiple repositories
- **Repository identification**: Multi-repo modes show repository names in brackets
- **Graceful error handling**: Handles missing directories and invalid repositories
- **Debug mode**: Set `DEBUG=1` for detailed logging

## How It Works

### Single Repository Mode (Default)
1. **Change Detection**:
   - Unstaged changes: `git diff --name-only HEAD`
   - Staged changes: `git diff --name-only --cached`
   - Untracked files: `git ls-files --others --exclude-standard`

2. **Directory Processing**:
   - Collects all immediate parent directories of changed files
   - Includes all parent directories up to repository root
   - Presents a sorted, unique list of directories

### Multi-Repository Mode
1. **Registry Management**:
   - Stores registered repository paths in `GIT_CHANGED_CD_REGISTERED_REPOS`
   - Colon-separated format for multiple repositories
   - In-memory storage (not persistent across shell sessions)

2. **Multi-Repo Scanning**:
   - Processes each repository independently
   - Combines results with sequential numbering
   - Displays repository names in brackets: `[repo-name] directory`

3. **Navigation**:
   - Uses absolute paths for cross-repository navigation
   - Handles edge cases (missing repos, non-git directories)

## Examples

### Basic Usage
```bash
$ gcd
Directories with changes:
1: <repo root>
2: src/utils
3: tests
Enter the number of the directory to cd into (or 0 to cancel): 2
Changing directory to: /path/to/repo/src/utils
```

### Multi-Repository Setup
```bash
$ git-changed-cd-add-repo /home/user/project1
Added repository: /home/user/project1

$ git-changed-cd-add-repo /home/user/project2
Added repository: /home/user/project2

$ gcdj
Directories with changes:
1: [project1] <repo root>
2: [project1] src
3: [project1] tests
4: [project2] <repo root>
5: [project2] docs
6: [project2] examples
Enter the number of the directory to cd into (or 0 to cancel): 5
Changing directory to: /home/user/project2/docs
```

### Debug Mode
```bash
$ DEBUG=1 gcd
DEBUG[git-changed-cd]: Starting git-changed-cd function with scan_mode=current
DEBUG[git-changed-cd]: Scanning current repository: /path/to/repo
DEBUG[git-changed-cd]: Processing repository: /path/to/repo
[...]
```

## Command Reference

### Core Commands
| Command | Alias | Description |
|---------|-------|-------------|
| `git-changed-cd` | `gcd` | Navigate to directories with changes (current repo) |
| `git-changed-cd --justRegisteredDirectories` | `gcdj` | Navigate within registered repositories only |
| `git-changed-cd --all` | `gcda` | Navigate within current + registered repositories |
| `git-changed-cd --help` | `gcd -h` | Show help message |

### Registry Management
| Command | Alias | Description |
|---------|-------|-------------|
| `git-changed-cd-add-repo <path>` | `gcd-add <path>` | Add repository to registry |
| `git-changed-cd-remove-repo <path>` | `gcd-remove <path>` | Remove repository from registry |

## Error Handling
The commands will exit with helpful error messages for:

### Navigation Errors
- Not in a Git repository (when required)
- No changes detected
- Invalid selection (non-number or out of range)
- Target directory doesn't exist

### Registry Errors
- Repository path is required (missing parameter)
- Directory doesn't exist
- Directory is not a Git repository
- Repository already registered (graceful, not an error)
- Repository not registered (graceful, not an error)

### Multi-Repository Handling
- Invalid/missing registered repositories are silently skipped during scanning
- No protection against nested Git repositories (not supported)
- No submodule support

## Global Variables
- `GIT_CHANGED_CD_REGISTERED_REPOS`: Colon-separated list of registered repository paths
- Automatically exported on first use
- Automatically unset when registry becomes empty
- Not persistent across shell sessions

## Requirements
- Bash shell
- Git installed and in PATH
- Running within a Git repository (for current repo operations)

## Installation Notes
The system is designed to work with existing installations. All functions use proper prefixed naming:
- Main functions: `git-changed-cd`, `git-changed-cd-add-repo`, `git-changed-cd-remove-repo`
- Helper functions: `git_changed_cd_*`
- Global variables: `GIT_CHANGED_CD_*`

## Limitations and Design Decisions
- **No persistence**: Registry is maintained in memory only
- **No stupidity protection**: Assumes users manage repositories responsibly
- **Single-user focused**: No concurrency protection for registry modifications
- **No nested repos**: Git repositories within Git repositories are not supported
- **No submodules**: Submodule support is not included
- **Path stability**: Assumes users don't move registered repositories

## Files Structure
```
src/
├── git-changed-cd.sh                          # Main navigation function
├── git-changed-cd-add-repo.sh                 # Repository addition
├── git-changed-cd-remove-repo.sh              # Repository removal
├── git_changed_cd_debug.sh                    # Debug utilities
├── git_changed_cd_add_dir_and_parents.sh      # Directory tree helpers
├── git_changed_cd_get_repo_directories.sh     # Single-repo directory scanner
└── git_changed_cd_registry.sh                 # Registry management functions

tests/
├── git_changed_cd_test_suite.sh               # Main test suite
└── subtests/                                  # Individual test files
    ├── git_changed_cd_test_*.sh               # Original functionality tests
    ├── git_changed_cd_test_add_repo_*.sh      # Repository addition tests
    ├── git_changed_cd_test_remove_repo_*.sh   # Repository removal tests
    └── git_changed_cd_test_*_mode.sh          # Multi-repo navigation tests
```

## Testing
The system includes comprehensive tests covering:
- Original single-repository functionality
- Repository registry management (add/remove)
- Multi-repository navigation modes
- Parameter validation and error handling
- Edge cases and error conditions

Run tests with:
```bash
git_changed_cd_test_suite
```

Note: Tests assume the system is already in use, so they validate functionality for existing users adding new repositories to their workflow.
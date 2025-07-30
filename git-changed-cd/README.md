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
- **Distance-based ordering**: Repositories ordered by proximity to current working directory
- **Change detection**: Staged, unstaged, and untracked files
- **Hierarchical structure**: Shows directory hierarchy with parent directories
- **Sequential numbering**: Consistent numbering across multiple repositories
- **Repository identification**: Multi-repo modes show repository names in brackets
- **Graceful error handling**: Handles missing directories and invalid repositories
- **Debug mode**: Set `DEBUG=1` for detailed logging

## Repository Display Precedence

### Current Mode (`gcd`)
- Shows only the current Git repository
- Directories displayed without repository name prefix
- Example: `src/utils`, `<repo root>`

### Registered Mode (`gcdj`)
- Shows only registered repositories
- **Ordered by distance** from current working directory (closest first)
- Directories displayed with repository name prefix
- Example: `[closest-repo] src`, `[farther-repo] docs`

### All Mode (`gcda`)
- Shows current repository + all registered repositories
- **All repositories ordered by distance** from current working directory
- All directories displayed with repository name prefix (including current)
- Example: `[current-repo] src`, `[nearby-repo] tests`, `[distant-repo] docs`

### Distance Calculation
Distance is calculated as the minimum number of directory traversals needed to reach the target repository from the current working directory:
- **Parent directory**: Distance 1 (up 1 level)
- **Child directory**: Distance 1 (down 1 level)
- **Sibling directory**: Distance 2 (up 1, down 1)
- **Cousin directory**: Distance varies based on common path depth

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

2. **Distance-Based Ordering**:
   - Calculates relative path distance from current working directory to each repository
   - Sorts repositories by distance (closest first)
   - Maintains consistent ordering regardless of registration order

3. **Multi-Repo Scanning**:
   - Processes each repository independently in distance order
   - Combines results with sequential numbering
   - Displays repository names in brackets: `[repo-name] directory`

4. **Navigation**:
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

### Multi-Repository Setup with Distance Ordering
```bash
# Current location: /home/user/workspace/current-project
$ git-changed-cd-add-repo /home/user/workspace/nearby-project
Added repository: /home/user/workspace/nearby-project

$ git-changed-cd-add-repo /home/user/projects/distant-project
Added repository: /home/user/projects/distant-project

$ gcdj
Directories with changes:
1: [nearby-project] <repo root>        # Distance: 1 (sibling directory)
2: [nearby-project] src
3: [nearby-project] tests
4: [distant-project] <repo root>       # Distance: 3 (cousin directory)
5: [distant-project] docs
6: [distant-project] examples
Enter the number of the directory to cd into (or 0 to cancel): 1
Changing directory to: /home/user/workspace/nearby-project
```

### All Mode with Current Repository
```bash
# From /home/user/workspace/current-project
$ gcda
Directories with changes:
1: [current-project] <repo root>       # Distance: 0 (current directory)
2: [current-project] src
3: [nearby-project] <repo root>        # Distance: 1 (sibling directory)
4: [nearby-project] tests
5: [distant-project] docs              # Distance: 3 (cousin directory)
Enter the number of the directory to cd into (or 0 to cancel): 3
Changing directory to: /home/user/workspace/nearby-project
```

### Debug Mode
```bash
$ DEBUG=1 gcd
DEBUG[git-changed-cd]: Starting git-changed-cd function with scan_mode=current
DEBUG[git-changed-cd]: Scanning current repository: /path/to/repo
DEBUG[git-changed-cd]: Processing repository: /path/to/repo
DEBUG[git-changed-cd]: Path distance calculation: common_length=3, steps_up=0, steps_down=2, total=2
[...]
```

## Command Reference

### Core Commands
| Command | Alias | Description |
|---------|-------|-------------|
| `git-changed-cd` | `gcd` | Navigate to directories with changes (current repo) |
| `git-changed-cd --justRegisteredDirectories` | `gcdj` | Navigate within registered repositories only (distance-ordered) |
| `git-changed-cd --all` | `gcda` | Navigate within current + registered repositories (distance-ordered) |
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
- **Distance calculation**: Based on directory traversal, not geographic or logical proximity

## Files Structure
```
src/
├── git-changed-cd.sh                          # Main navigation function
├── git-changed-cd-add-repo.sh                 # Repository addition
├── git-changed-cd-remove-repo.sh              # Repository removal
├── git_changed_cd_debug.sh                    # Debug utilities
├── git_changed_cd_add_dir_and_parents.sh      # Directory tree helpers
├── git_changed_cd_get_repo_directories.sh     # Single-repo directory scanner
├── git_changed_cd_registry.sh                 # Registry management functions
└── git_changed_cd_path_distance.sh            # Distance calculation utilities

tests/
├── git_changed_cd_test_suite.sh               # Main test suite
└── subtests/                                  # Individual test files
    ├── core/                                  # Original functionality tests
    │   ├── git_changed_cd_test_*.sh
    │   └── README.md
    ├── registry/                              # Registry management tests
    │   ├── add/git_changed_cd_test_add_repo_*.sh
    │   ├── remove/git_changed_cd_test_remove_repo_*.sh
    │   ├── functions/git_changed_cd_test_registry_functions.sh
    │   └── README.md
    ├── multi_repo/                           # Multi-repository tests
    │   ├── modes/git_changed_cd_test_*_mode.sh
    │   ├── navigation/git_changed_cd_test_*.sh
    │   └── README.md
    ├── error_handling/                       # Error condition tests
    │   ├── validation/git_changed_cd_test_invalid_*.sh
    │   ├── edge_cases/git_changed_cd_test_*.sh
    │   └── README.md
    └── ui/                                   # User interface tests
        ├── aliases/git_changed_cd_test_aliases.sh
        ├── help/git_changed_cd_test_help_message.sh
        ├── input_validation/git_changed_cd_test_*.sh
        └── README.md
```

## Testing
The system includes comprehensive tests covering:
- Original single-repository functionality
- Repository registry management (add/remove)
- Multi-repository navigation modes with distance ordering
- Path distance calculation accuracy
- Parameter validation and error handling
- Edge cases and error conditions
- User interface elements (aliases, help, input validation)

Run tests with:
```bash
git_changed_cd_test_suite
```

### Test Categories
- **Core functionality**: Basic navigation and change detection
- **Registry management**: Adding, removing, and validating repositories
- **Multi-repository navigation**: Distance-based ordering and cross-repo navigation
- **Error handling**: Input validation and edge case management
- **User interface**: Aliases, help system, and user interaction

Note: Tests assume the system is already in use, so they validate functionality for existing users adding new repositories to their workflow.

## Performance Considerations
- **Distance calculation**: O(n) where n is the number of registered repositories
- **Path parsing**: Efficient string operations using bash built-ins
- **Repository validation**: Minimal git operations per repository
- **Memory usage**: Registry stored in single environment variable
- **Sorting overhead**: Negligible for typical repository counts (< 20)
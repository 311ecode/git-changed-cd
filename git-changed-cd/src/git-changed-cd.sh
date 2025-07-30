#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

git-changed-cd() {
  # Only show debug output if DEBUG is set

  git_changed_cd_debug "Starting git-changed-cd function"

  # Get the root of the Git repository
  git_changed_cd_debug "Getting repository root..."
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z $repo_root ]]; then
    git_changed_cd_debug "Failed to get repository root - not in a git repo?"
    echo "Error: Not inside a Git repository." >&2
    return 1
  fi
  git_changed_cd_debug "Repository root: $repo_root"

  # Use pushd/popd for reliable directory navigation within the function
  git_changed_cd_debug "Attempting to pushd to repo root..."
  pushd "$repo_root" >/dev/null || {
    git_changed_cd_debug "Failed to pushd to repo root: $repo_root"
    echo "Error: Failed to navigate to repository root '$repo_root'." >&2
    return 1
  }
  git_changed_cd_debug "Successfully changed to repository root directory"

  # Get lists of files: unstaged, staged, and untracked (including not-yet-added)
  git_changed_cd_debug "Getting unstaged files..."
  local unstaged_files=$(git diff --name-only HEAD 2>/dev/null)
  git_changed_cd_debug "Unstaged files:
$unstaged_files"
  git_changed_cd_debug "Unstaged files count: $(echo "$unstaged_files" | grep -c '^')"

  git_changed_cd_debug "Getting staged files..."
  local staged_files=$(git diff --name-only --cached 2>/dev/null)
  git_changed_cd_debug "Staged files:
$staged_files"
  git_changed_cd_debug "Staged files count: $(echo "$staged_files" | grep -c '^')"

  git_changed_cd_debug "Getting untracked files (including not-yet-added)..."
  local untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null)
  git_changed_cd_debug "Raw untracked files output:
$untracked_files"
  git_changed_cd_debug "Untracked files count: $(echo "$untracked_files" | grep -c '^')"
  git_changed_cd_debug "Sample untracked files (first 5):"
  [[ -n $DEBUG ]] && echo "$untracked_files" | head -n 5 | while read -r line; do git_changed_cd_debug " - $line"; done

  # Combine, sort unique, and filter empty lines
  git_changed_cd_debug "Combining all changed files..."
  local all_files=$(printf "%s
%s
%s" "$unstaged_files" "$staged_files" "$untracked_files" | grep -v '^[[:space:]]*$' | sort -u)
  git_changed_cd_debug "Combined files:
$all_files"
  git_changed_cd_debug "Total unique changed files: $(echo "$all_files" | grep -c '^')"
  git_changed_cd_debug "Sample changed files (first 5):"
  [[ -n $DEBUG ]] && echo "$all_files" | head -n 5 | while read -r line; do git_changed_cd_debug " - $line"; done

  if [[ -z $all_files ]]; then
    git_changed_cd_debug "No changed files detected"
    echo "No changes detected (staged, unstaged, or untracked)."
    popd >/dev/null # Return to original directory
    return 0
  fi

  # Collect all directories containing changes (immediate parents)
  git_changed_cd_debug "Collecting immediate parent directories..."
  local immediate_dirs=()
  while IFS= read -r file; do
    local dir
    dir=$(dirname "$file")
    immediate_dirs+=("$dir")
    git_changed_cd_debug "File: $file → Parent dir: $dir"
  done <<<"$all_files"
  git_changed_cd_debug "Found ${#immediate_dirs[@]} immediate directories"

  # Generate the list of all relevant directories, including parents
  git_changed_cd_debug "Generating all relevant directories..."
  local all_relevant_dirs=()
  local seen_dirs="" # Use a string for quick check (less efficient for huge lists but fine here)

  # Function to add a directory and its parents to the list if not seen

  # Process each immediate directory to add it and its parents
  git_changed_cd_debug "Processing immediate directories..."
  for dir in "${immediate_dirs[@]}"; do
    git_changed_cd_debug "Processing immediate directory: '$dir'"
    git_changed_cd_add_dir_and_parents "$dir"
  done

  # Sort the unique list of relevant directories naturally (-V)
  git_changed_cd_debug "Sorting unique relevant directories..."
  IFS=$'
' unique_relevant_directories=($(printf "%s
" "${all_relevant_dirs[@]}" | sort -uV))
  unset IFS
  git_changed_cd_debug "Found ${#unique_relevant_directories[@]} unique relevant directories"
  git_changed_cd_debug "All relevant directories:"
  [[ -n $DEBUG ]] && printf "%s
" "${unique_relevant_directories[@]}" | while read -r line; do git_changed_cd_debug " - $line"; done

  if [[ ${#unique_relevant_directories[@]} -eq 0 ]]; then
    git_changed_cd_debug "No directories found - unexpected state"
    echo "No directories found containing changes (unexpected state)." >&2
    popd >/dev/null
    return 1
  fi

  # Display directories with numbers
  git_changed_cd_debug "Displaying directory selection menu..."
  echo "Directories with changes:"
  local i
  for i in "${!unique_relevant_directories[@]}"; do
    local display_dir="${unique_relevant_directories[i]}"
    # Display '.' as '<repo root>' for better readability
    if [[ $display_dir == "." ]]; then
      display_dir="<repo root>"
    fi
    printf "%d: %s
" "$((i + 1))" "$display_dir"
  done

  # Prompt user for selection
  git_changed_cd_debug "Prompting user for selection..."
  local selection
  read -p "Enter the number of the directory to cd into (or 0 to cancel): " selection
  git_changed_cd_debug "User entered selection: $selection"

  # Validate selection is a number
  if [[ ! $selection =~ ^[0-9]+$ ]]; then
    git_changed_cd_debug "Invalid input detected (not a number)"
    echo "Invalid input: Not a number." >&2
    popd >/dev/null # Return to original directory
    return 1
  fi

  # Handle cancellation
  if ((selection == 0)); then
    git_changed_cd_debug "User cancelled operation"
    echo "Operation cancelled."
    popd >/dev/null # Return to original directory
    return 0
  fi

  # Validate selection range
  if ((selection >= 1 && selection <= ${#unique_relevant_directories[@]})); then
    local selected_dir_rel="${unique_relevant_directories[selection - 1]}" # Path relative to repo_root
    git_changed_cd_debug "Selected directory (relative): '$selected_dir_rel'"

    # We need to popd *first* to get back to the original directory,
    # then cd to the target directory using its absolute path.
    local target_dir_abs
    if [[ $selected_dir_rel == "." ]]; then
      target_dir_abs="$repo_root"
      git_changed_cd_debug "Handling root directory case: '$target_dir_abs'"
    else
      target_dir_abs="$repo_root/$selected_dir_rel"
      git_changed_cd_debug "Computed target path: '$target_dir_abs'"
    fi

    popd >/dev/null # Return to original directory *before* final cd

    if [[ -d $target_dir_abs ]]; then
      git_changed_cd_debug "Changing to target directory: '$target_dir_abs'"
      echo "Changing directory to: $target_dir_abs"
      cd "$target_dir_abs" || {
        git_changed_cd_debug "Failed to cd into '$target_dir_abs'"
        echo "Error: Failed to cd into '$target_dir_abs'." >&2
        return 1
      }
      git_changed_cd_debug "Successfully changed directory"
      return 0
    else
      git_changed_cd_debug "Target directory doesn't exist: '$target_dir_abs'"
      echo "Error: Selected directory '$target_dir_abs' seems to not exist." >&2
      return 1
    fi
  else
    git_changed_cd_debug "Selection out of range: $selection"
    echo "Invalid selection number: $selection" >&2
    popd >/dev/null # Return to original directory
    return 1
  fi
}

# Define the alias
alias gcd='git-changed-cd'

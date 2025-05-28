# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
git-changed-cd() {
  # Only show debug output if DEBUG is set
  git-changed-cd-debug() {
    [[ -n $DEBUG ]] && echo "DEBUG[git-changed-cd]: $1" >&2
  }

  git-changed-cd-debug "Starting git-changed-cd function"

  # Get the root of the Git repository
  git-changed-cd-debug "Getting repository root..."
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z $repo_root ]]; then
    git-changed-cd-debug "Failed to get repository root - not in a git repo?"
    echo "Error: Not inside a Git repository." >&2
    return 1
  fi
  git-changed-cd-debug "Repository root: $repo_root"

  # Use pushd/popd for reliable directory navigation within the function
  git-changed-cd-debug "Attempting to pushd to repo root..."
  pushd "$repo_root" >/dev/null || {
    git-changed-cd-debug "Failed to pushd to repo root: $repo_root"
    echo "Error: Failed to navigate to repository root '$repo_root'." >&2
    return 1
  }
  git-changed-cd-debug "Successfully changed to repository root directory"

  # Get lists of files: unstaged, staged, and untracked (including not-yet-added)
  git-changed-cd-debug "Getting unstaged files..."
  local unstaged_files=$(git diff --name-only HEAD 2>/dev/null)
  git-changed-cd-debug "Unstaged files:
$unstaged_files"
  git-changed-cd-debug "Unstaged files count: $(echo "$unstaged_files" | grep -c '^')"

  git-changed-cd-debug "Getting staged files..."
  local staged_files=$(git diff --name-only --cached 2>/dev/null)
  git-changed-cd-debug "Staged files:
$staged_files"
  git-changed-cd-debug "Staged files count: $(echo "$staged_files" | grep -c '^')"

  git-changed-cd-debug "Getting untracked files (including not-yet-added)..."
  local untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null)
  git-changed-cd-debug "Raw untracked files output:
$untracked_files"
  git-changed-cd-debug "Untracked files count: $(echo "$untracked_files" | grep -c '^')"
  git-changed-cd-debug "Sample untracked files (first 5):"
  [[ -n $DEBUG ]] && echo "$untracked_files" | head -n 5 | while read -r line; do git-changed-cd-debug " - $line"; done

  # Combine, sort unique, and filter empty lines
  git-changed-cd-debug "Combining all changed files..."
  local all_files=$(printf "%s
%s
%s" "$unstaged_files" "$staged_files" "$untracked_files" | grep -v '^[[:space:]]*$' | sort -u)
  git-changed-cd-debug "Combined files:
$all_files"
  git-changed-cd-debug "Total unique changed files: $(echo "$all_files" | grep -c '^')"
  git-changed-cd-debug "Sample changed files (first 5):"
  [[ -n $DEBUG ]] && echo "$all_files" | head -n 5 | while read -r line; do git-changed-cd-debug " - $line"; done

  if [[ -z $all_files ]]; then
    git-changed-cd-debug "No changed files detected"
    echo "No changes detected (staged, unstaged, or untracked)."
    popd >/dev/null # Return to original directory
    return 0
  fi

  # Collect all directories containing changes (immediate parents)
  git-changed-cd-debug "Collecting immediate parent directories..."
  local immediate_dirs=()
  while IFS= read -r file; do
    local dir
    dir=$(dirname "$file")
    immediate_dirs+=("$dir")
    git-changed-cd-debug "File: $file → Parent dir: $dir"
  done <<<"$all_files"
  git-changed-cd-debug "Found ${#immediate_dirs[@]} immediate directories"

  # Generate the list of all relevant directories, including parents
  git-changed-cd-debug "Generating all relevant directories..."
  local all_relevant_dirs=()
  local seen_dirs="" # Use a string for quick check (less efficient for huge lists but fine here)

  # Function to add a directory and its parents to the list if not seen
  git-changed-cd-add_dir_and_parents() {
    local current_dir="$1"
    git-changed-cd-debug "Processing directory: $current_dir"
    while [[ $current_dir != "/" && $current_dir != "" ]]; do
      # Check if directory has already been added (simple string search)
      if [[ $seen_dirs != *";$current_dir;"* ]]; then
        all_relevant_dirs+=("$current_dir")
        seen_dirs+=";$current_dir;"
        git-changed-cd-debug "Added directory to relevant list: '$current_dir'"
      fi
      # Move up to the parent directory
      if [[ $current_dir == "." ]]; then
        # Special case for root, stop
        break
      fi
      current_dir=$(dirname "$current_dir")
      git-changed-cd-debug "Moved up to parent: $current_dir"
    done
    # Ensure root is added if not already
    if [[ $seen_dirs != *";.;"* ]]; then
      all_relevant_dirs+=(".")
      seen_dirs+=";.;"
      git-changed-cd-debug "Added root directory to relevant list"
    fi
  }

  # Process each immediate directory to add it and its parents
  git-changed-cd-debug "Processing immediate directories..."
  for dir in "${immediate_dirs[@]}"; do
    git-changed-cd-debug "Processing immediate directory: '$dir'"
    git-changed-cd-add_dir_and_parents "$dir"
  done

  # Sort the unique list of relevant directories naturally (-V)
  git-changed-cd-debug "Sorting unique relevant directories..."
  IFS=$'
' unique_relevant_directories=($(printf "%s
" "${all_relevant_dirs[@]}" | sort -uV))
  unset IFS
  git-changed-cd-debug "Found ${#unique_relevant_directories[@]} unique relevant directories"
  git-changed-cd-debug "All relevant directories:"
  [[ -n $DEBUG ]] && printf "%s
" "${unique_relevant_directories[@]}" | while read -r line; do git-changed-cd-debug " - $line"; done

  if [[ ${#unique_relevant_directories[@]} -eq 0 ]]; then
    git-changed-cd-debug "No directories found - unexpected state"
    echo "No directories found containing changes (unexpected state)." >&2
    popd >/dev/null
    return 1
  fi

  # Display directories with numbers
  git-changed-cd-debug "Displaying directory selection menu..."
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
  git-changed-cd-debug "Prompting user for selection..."
  local selection
  read -p "Enter the number of the directory to cd into (or 0 to cancel): " selection
  git-changed-cd-debug "User entered selection: $selection"

  # Validate selection is a number
  if [[ ! $selection =~ ^[0-9]+$ ]]; then
    git-changed-cd-debug "Invalid input detected (not a number)"
    echo "Invalid input: Not a number." >&2
    popd >/dev/null # Return to original directory
    return 1
  fi

  # Handle cancellation
  if ((selection == 0)); then
    git-changed-cd-debug "User cancelled operation"
    echo "Operation cancelled."
    popd >/dev/null # Return to original directory
    return 0
  fi

  # Validate selection range
  if ((selection >= 1 && selection <= ${#unique_relevant_directories[@]})); then
    local selected_dir_rel="${unique_relevant_directories[selection - 1]}" # Path relative to repo_root
    git-changed-cd-debug "Selected directory (relative): '$selected_dir_rel'"

    # We need to popd *first* to get back to the original directory,
    # then cd to the target directory using its absolute path.
    local target_dir_abs="$repo_root/$selected_dir_rel"
    git-changed-cd-debug "Initial target path: '$target_dir_abs'"

    # 'cd' handles '.' correctly, but canonicalizing is cleaner
    if [[ $selected_dir_rel == "." ]]; then
      target_dir_abs="$repo_root"
      git-changed-cd-debug "Handling root directory case"
    else
      # Use cd and pwd to resolve the absolute path robustly
      git-changed-cd-debug "Resolving absolute path for '$repo_root/$selected_dir_rel'"
      target_dir_abs=$(cd "$repo_root/$selected_dir_rel" && pwd -P) # Use -P for physical path
      if [[ -z $target_dir_abs ]]; then
        git-changed-cd-debug "Failed to resolve path for '$selected_dir_rel'"
        echo "Error: Could not resolve path for '$selected_dir_rel'." >&2
        popd >/dev/null
        return 1
      fi
    fi
    git-changed-cd-debug "Final target path: '$target_dir_abs'"

    popd >/dev/null # Return to original directory *before* final cd

    if [[ -d $target_dir_abs ]]; then
      git-changed-cd-debug "Changing to target directory..."
      echo "Changing directory to: $target_dir_abs"
      cd "$target_dir_abs" || {
        git-changed-cd-debug "Failed to cd into '$target_dir_abs'"
        echo "Error: Failed to cd into '$target_dir_abs'." >&2
        return 1
      } # Use the absolute path
    else
      git-changed-cd-debug "Target directory doesn't exist: '$target_dir_abs'"
      echo "Error: Selected directory '$target_dir_abs' seems to not exist." >&2
      return 1
    fi
  else
    git-changed-cd-debug "Selection out of range: $selection"
    echo "Invalid selection number: $selection" >&2
    popd >/dev/null # Return to original directory
    return 1
  fi

  git-changed-cd-debug "Successfully changed directory"
}

# Define the alias
alias gcd='git-changed-cd'

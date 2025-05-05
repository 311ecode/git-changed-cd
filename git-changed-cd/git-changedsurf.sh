git-changedsurf() {
  # Get the root of the Git repository
  local repo_root=$(git rev-parse --show-toplevel)
  if [[ -z $repo_root ]]; then
    echo "Error: Not inside a Git repository." >&2
    return 1
  fi

  # Use pushd/popd for reliable directory navigation within the function
  pushd "$repo_root" >/dev/null || {
    echo "Error: Failed to navigate to repository root '$repo_root'." >&2
    return 1
  }

  # Get lists of files: unstaged, staged, and untracked
  local unstaged_files=$(git diff --name-only HEAD)
  local staged_files=$(git diff --name-only --cached)
  local untracked_files=$(git ls-files --others --exclude-standard)

  # Combine, sort unique, and filter empty lines
  local all_files=$(printf "%s\n%s\n%s" "$unstaged_files" "$staged_files" "$untracked_files" | grep -v '^[[:space:]]*$' | sort -u)

  if [[ -z $all_files ]]; then
    echo "No changes detected (staged, unstaged, or untracked)."
    popd >/dev/null # Return to original directory
    return 0
  fi

  # Collect all directories containing changes (immediate parents)
  local immediate_dirs=()
  while IFS= read -r file; do
    local dir
    dir=$(dirname "$file")
    immediate_dirs+=("$dir")
  done <<<"$all_files"

  # Generate the list of all relevant directories, including parents
  local all_relevant_dirs=()
  local seen_dirs="" # Use a string for quick check (less efficient for huge lists but fine here)

  # Function to add a directory and its parents to the list if not seen
  add_dir_and_parents() {
    local current_dir="$1"
    while [[ $current_dir != "/" && $current_dir != "" ]]; do
      # Check if directory has already been added (simple string search)
      # This is a performance bottleneck for very large numbers of directories
      # A more robust solution for many directories would use an associative array in Bash 4+
      if [[ $seen_dirs != *";$current_dir;"* ]]; then
        all_relevant_dirs+=("$current_dir")
        seen_dirs+=";$current_dir;"
      fi
      # Move up to the parent directory
      if [[ $current_dir == "." ]]; then
        # Special case for root, stop
        break
      fi
      current_dir=$(dirname "$current_dir")
    done
    # Ensure root is added if not already
    if [[ $seen_dirs != *";.;"* ]]; then
      all_relevant_dirs+=(".")
      seen_dirs+=";.;"
    fi
  }

  # Process each immediate directory to add it and its parents
  for dir in "${immediate_dirs[@]}"; do
    add_dir_and_parents "$dir"
  done

  # Sort the unique list of relevant directories naturally (-V)
  IFS=$'\n' unique_relevant_directories=($(printf "%s\n" "${all_relevant_dirs[@]}" | sort -uV))
  unset IFS

  if [[ ${#unique_relevant_directories[@]} -eq 0 ]]; then
    echo "No directories found containing changes (unexpected state)." >&2
    popd >/dev/null
    return 1
  fi

  # Display directories with numbers
  echo "Directories with changes:"
  local i
  for i in "${!unique_relevant_directories[@]}"; do
    local display_dir="${unique_relevant_directories[i]}"
    # Display '.' as '<repo root>' for better readability
    if [[ $display_dir == "." ]]; then
      display_dir="<repo root>"
    fi
    printf "%d: %s\n" "$((i + 1))" "$display_dir"
  done

  # Prompt user for selection
  local selection
  read -p "Enter the number of the directory to cd into (or 0 to cancel): " selection

  # Validate selection is a number
  if [[ ! $selection =~ ^[0-9]+$ ]]; then
    echo "Invalid input: Not a number." >&2
    popd >/dev/null # Return to original directory
    return 1
  fi

  # Handle cancellation
  if ((selection == 0)); then
    echo "Operation cancelled."
    popd >/dev/null # Return to original directory
    return 0
  fi

  # Validate selection range
  if ((selection >= 1 && selection <= ${#unique_relevant_directories[@]})); then
    local selected_dir_rel="${unique_relevant_directories[selection - 1]}" # Path relative to repo_root

    # We need to popd *first* to get back to the original directory,
    # then cd to the target directory using its absolute path.
    local target_dir_abs="$repo_root/$selected_dir_rel"
    # Use realpath or similar to clean up the path (e.g., remove trailing /.)
    # 'cd' handles '.' correctly, but canonicalizing is cleaner
    if [[ $selected_dir_rel == "." ]]; then
      target_dir_abs="$repo_root"
    else
      # Use cd and pwd to resolve the absolute path robustly
      # Doing this in a subshell prevents changing the current directory prematurely
      target_dir_abs=$(cd "$repo_root/$selected_dir_rel" && pwd -P) # Use -P for physical path
      if [[ -z $target_dir_abs ]]; then
        echo "Error: Could not resolve path for '$selected_dir_rel'." >&2
        popd >/dev/null
        return 1
      fi
    fi

    popd >/dev/null # Return to original directory *before* final cd

    if [[ -d $target_dir_abs ]]; then
      echo "Changing directory to: $target_dir_abs"
      cd "$target_dir_abs" || {
        echo "Error: Failed to cd into '$target_dir_abs'." >&2
        return 1
      } # Use the absolute path
    else
      # This check is slightly redundant if 'cd && pwd' worked, but safe
      echo "Error: Selected directory '$target_dir_abs' seems to not exist." >&2
      return 1
    fi
  else
    echo "Invalid selection number: $selection" >&2
    popd >/dev/null # Return to original directory
    return 1
  fi

  # If cd was successful, the shell is now in the new directory
  # The function implicitly returns 0 (success)
}

# Define the alias
alias gcd='git-changedsurf'

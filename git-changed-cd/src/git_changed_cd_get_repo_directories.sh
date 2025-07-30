#!/usr/bin/env bash

git_changed_cd_get_repo_directories() {
  local repo_root="$1"
  
  git_changed_cd_debug "Getting directories for repository: $repo_root"
  
  # Use pushd/popd for reliable directory navigation within the function
  git_changed_cd_debug "Attempting to pushd to repo root..."
  pushd "$repo_root" >/dev/null || {
    git_changed_cd_debug "Failed to pushd to repo root: $repo_root"
    return 1
  }
  git_changed_cd_debug "Successfully changed to repository root directory"

  # Get lists of files: unstaged, staged, and untracked (including not-yet-added)
  git_changed_cd_debug "Getting unstaged files..."
  local unstaged_files=$(git diff --name-only HEAD 2>/dev/null)
  git_changed_cd_debug "Unstaged files count: $(echo "$unstaged_files" | grep -c '^' 2>/dev/null || echo 0)"

  git_changed_cd_debug "Getting staged files..."
  local staged_files=$(git diff --name-only --cached 2>/dev/null)
  git_changed_cd_debug "Staged files count: $(echo "$staged_files" | grep -c '^' 2>/dev/null || echo 0)"

  git_changed_cd_debug "Getting untracked files..."
  local untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null)
  git_changed_cd_debug "Untracked files count: $(echo "$untracked_files" | grep -c '^' 2>/dev/null || echo 0)"

  # Combine, sort unique, and filter empty lines
  git_changed_cd_debug "Combining all changed files..."
  local all_files=$(printf "%s\n%s\n%s" "$unstaged_files" "$staged_files" "$untracked_files" | grep -v '^[[:space:]]*$' | sort -u)
  git_changed_cd_debug "Total unique changed files: $(echo "$all_files" | grep -c '^' 2>/dev/null || echo 0)"

  popd >/dev/null # Return to original directory

  if [[ -z $all_files ]]; then
    git_changed_cd_debug "No changed files detected in $repo_root"
    return 1
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
  local seen_dirs="" # Use a string for quick check

  # Process each immediate directory to add it and its parents
  git_changed_cd_debug "Processing immediate directories..."
  for dir in "${immediate_dirs[@]}"; do
    git_changed_cd_debug "Processing immediate directory: '$dir'"
    git_changed_cd_add_dir_and_parents_local "$dir"
  done

  # Sort the unique list of relevant directories naturally (-V)
  git_changed_cd_debug "Sorting unique relevant directories..."
  IFS=$'\n' unique_relevant_directories=($(printf "%s\n" "${all_relevant_dirs[@]}" | sort -uV))
  unset IFS
  git_changed_cd_debug "Found ${#unique_relevant_directories[@]} unique relevant directories"

  # Output the directories
  printf "%s\n" "${unique_relevant_directories[@]}"
  return 0
}

# Local version of the add_dir_and_parents function to avoid global variable conflicts
git_changed_cd_add_dir_and_parents_local() {
  local current_dir="$1"
  git_changed_cd_debug "Processing directory: $current_dir"
  while [[ $current_dir != "/" && $current_dir != "" ]]; do
    # Check if directory has already been added (simple string search)
    if [[ $seen_dirs != *";$current_dir;"* ]]; then
      all_relevant_dirs+=("$current_dir")
      seen_dirs+=";$current_dir;"
      git_changed_cd_debug "Added directory to relevant list: '$current_dir'"
    fi
    # Move up to the parent directory
    if [[ $current_dir == "." ]]; then
      # Special case for root, stop
      break
    fi
    current_dir=$(dirname "$current_dir")
    git_changed_cd_debug "Moved up to parent: $current_dir"
  done
  # Ensure root is added if not already
  if [[ $seen_dirs != *";.;"* ]]; then
    all_relevant_dirs+=(".")
    seen_dirs+=";.;"
    git_changed_cd_debug "Added root directory to relevant list"
  fi
}
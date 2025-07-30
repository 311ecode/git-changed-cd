#!/usr/bin/env bash
git_changed_cd_add_dir_and_parents() {
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

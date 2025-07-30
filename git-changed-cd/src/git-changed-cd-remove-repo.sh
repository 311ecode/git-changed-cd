#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

git-changed-cd-remove-repo() {
  local repo_path="$1"
  
  # Check if path parameter was provided
  if [[ -z "$repo_path" ]]; then
    echo "Error: Repository path is required." >&2
    echo "Usage: git-changed-cd-remove-repo <path>" >&2
    return 1
  fi
  
  # Get absolute path if directory exists, otherwise use as-is
  local abs_path
  if [[ -d "$repo_path" ]]; then
    abs_path=$(cd "$repo_path" && pwd) || {
      echo "Error: Failed to resolve absolute path for '$repo_path'." >&2
      return 1
    }
  else
    abs_path="$repo_path"
  fi
  
  git_changed_cd_debug "Removing repository: $abs_path"
  
  # Initialize registry if needed
  git_changed_cd_registry_init
  
  # Check if registered
  if ! git_changed_cd_registry_contains "$abs_path"; then
    echo "Repository '$abs_path' is not registered."
    return 0
  fi
  
  # Remove from registry
  git_changed_cd_registry_remove "$abs_path"
  echo "Removed repository: $abs_path"
  return 0
}

# Define the alias
alias gcd-remove='git-changed-cd-remove-repo'
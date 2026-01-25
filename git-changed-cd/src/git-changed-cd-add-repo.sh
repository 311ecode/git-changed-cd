#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

git-changed-cd-add-repo() {
  local repo_path="$1"

  # Check if path parameter was provided
  if [[ -z $repo_path ]]; then
    echo "Error: Repository path is required." >&2
    echo "Usage: git-changed-cd-add-repo <path>" >&2
    return 1
  fi

  # Check if directory exists
  if [[ ! -d $repo_path ]]; then
    echo "Error: Directory '$repo_path' does not exist." >&2
    return 1
  fi

  # Check if it's a Git repository
  if ! git -C "$repo_path" rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: '$repo_path' is not a Git repository." >&2
    return 1
  fi

  # Get absolute path
  local abs_path
  abs_path=$(cd "$repo_path" && pwd) || {
    echo "Error: Failed to resolve absolute path for '$repo_path'." >&2
    return 1
  }

  git_changed_cd_debug "Adding repository: $abs_path"

  # Initialize registry if needed
  git_changed_cd_registry_init

  # Check if already registered
  if git_changed_cd_registry_contains "$abs_path"; then
    echo "Repository '$abs_path' is already registered."
    return 0
  fi

  # Add to registry
  git_changed_cd_registry_add "$abs_path"
  echo "Added repository: $abs_path"
  return 0
}

# Define the alias
alias gcd-add='git-changed-cd-add-repo'

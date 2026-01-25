#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

git-changed-cd-list-repos() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      echo "Usage: git-changed-cd-list-repos [OPTIONS]"
      echo ""
      echo "List all registered repositories."
      echo ""
      echo "OPTIONS:"
      echo "  -h, --help    Show this help message"
      echo ""
      echo "ALIASES:"
      echo "  gcd-list     - git-changed-cd-list-repos"
      return 0
      ;;
    *)
      echo "Error: Unknown option '$1'" >&2
      echo "Use 'git-changed-cd-list-repos --help' for usage information." >&2
      return 1
      ;;
    esac
  done

  git_changed_cd_debug "Listing registered repositories"

  # Initialize registry if needed
  git_changed_cd_registry_init

  # Get count of registered repositories
  local registry_count=$(git_changed_cd_registry_count)

  if [[ $registry_count -eq 0 ]]; then
    echo "No registered repositories found."
    echo "Use 'git-changed-cd-add-repo <path>' to register repositories."
    return 0
  fi

  echo "Registered repositories ($registry_count):"

  # Get all repositories and display them
  local index=1
  while IFS= read -r repo; do
    echo "$index: $repo"
    ((index++))
  done < <(git_changed_cd_registry_get_repos)

  return 0
}

# Define the alias
alias gcd-list='git-changed-cd-list-repos'

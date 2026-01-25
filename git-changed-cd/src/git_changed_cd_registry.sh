#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

# Initialize the registry variable if it doesn't exist
git_changed_cd_registry_init() {
  if [[ -z ${GIT_CHANGED_CD_REGISTERED_REPOS:-} ]]; then
    export GIT_CHANGED_CD_REGISTERED_REPOS=""
    git_changed_cd_debug "Initialized empty registry"
  fi
}

# Add a repository to the registry
git_changed_cd_registry_add() {
  local repo_path="$1"
  git_changed_cd_debug "Registry add: $repo_path"

  if [[ -z $GIT_CHANGED_CD_REGISTERED_REPOS ]]; then
    export GIT_CHANGED_CD_REGISTERED_REPOS="$repo_path"
  else
    export GIT_CHANGED_CD_REGISTERED_REPOS="$GIT_CHANGED_CD_REGISTERED_REPOS:$repo_path"
  fi
  git_changed_cd_debug "Registry now: $GIT_CHANGED_CD_REGISTERED_REPOS"
}

# Remove a repository from the registry
git_changed_cd_registry_remove() {
  local repo_path="$1"
  git_changed_cd_debug "Registry remove: $repo_path"

  if [[ -z $GIT_CHANGED_CD_REGISTERED_REPOS ]]; then
    git_changed_cd_debug "Registry is empty, nothing to remove"
    return 0
  fi

  # Convert colon-separated string to array
  IFS=':' read -ra repos <<<"$GIT_CHANGED_CD_REGISTERED_REPOS"

  # Rebuild registry without the specified repo
  local new_registry=""
  local found=false
  for repo in "${repos[@]}"; do
    if [[ $repo != "$repo_path" ]]; then
      if [[ -z $new_registry ]]; then
        new_registry="$repo"
      else
        new_registry="$new_registry:$repo"
      fi
    else
      found=true
    fi
  done

  if [[ $found == true ]]; then
    if [[ -z $new_registry ]]; then
      unset GIT_CHANGED_CD_REGISTERED_REPOS
      git_changed_cd_debug "Registry is now empty, unset variable"
    else
      export GIT_CHANGED_CD_REGISTERED_REPOS="$new_registry"
      git_changed_cd_debug "Registry now: $GIT_CHANGED_CD_REGISTERED_REPOS"
    fi
  else
    git_changed_cd_debug "Repository not found in registry"
  fi
}

# Check if a repository is in the registry
git_changed_cd_registry_contains() {
  local repo_path="$1"
  git_changed_cd_debug "Registry contains check: $repo_path"

  if [[ -z $GIT_CHANGED_CD_REGISTERED_REPOS ]]; then
    git_changed_cd_debug "Registry is empty"
    return 1
  fi

  IFS=':' read -ra repos <<<"$GIT_CHANGED_CD_REGISTERED_REPOS"
  for repo in "${repos[@]}"; do
    if [[ $repo == "$repo_path" ]]; then
      git_changed_cd_debug "Repository found in registry"
      return 0
    fi
  done

  git_changed_cd_debug "Repository not found in registry"
  return 1
}

# Get all repositories from the registry (one per line)
git_changed_cd_registry_get_repos() {
  git_changed_cd_debug "Getting all repos from registry"

  if [[ -z $GIT_CHANGED_CD_REGISTERED_REPOS ]]; then
    git_changed_cd_debug "Registry is empty"
    return 0
  fi

  IFS=':' read -ra repos <<<"$GIT_CHANGED_CD_REGISTERED_REPOS"
  for repo in "${repos[@]}"; do
    if [[ -n $repo ]]; then
      echo "$repo"
      git_changed_cd_debug "Registry repo: $repo"
    fi
  done
}

# Get count of repositories in the registry
git_changed_cd_registry_count() {
  git_changed_cd_debug "Getting registry count"

  if [[ -z $GIT_CHANGED_CD_REGISTERED_REPOS ]]; then
    echo "0"
    return 0
  fi

  IFS=':' read -ra repos <<<"$GIT_CHANGED_CD_REGISTERED_REPOS"
  local count=0
  for repo in "${repos[@]}"; do
    if [[ -n $repo ]]; then
      ((count++))
    fi
  done

  echo "$count"
  git_changed_cd_debug "Registry count: $count"
}

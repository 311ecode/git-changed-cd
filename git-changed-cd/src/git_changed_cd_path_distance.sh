#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

# Calculate the relative path distance from current directory to a target path
git_changed_cd_calculate_path_distance() {
  local target_path="$1"
  local current_path="${PWD}"

  git_changed_cd_debug "Calculating distance from '$current_path' to '$target_path'"

  # Convert both paths to absolute paths
  local abs_target
  local abs_current

  abs_target=$(cd "$target_path" 2>/dev/null && pwd) || abs_target="$target_path"
  abs_current="$current_path"

  # Split paths into components
  IFS='/' read -ra target_parts <<< "$abs_target"
  IFS='/' read -ra current_parts <<< "$abs_current"

  # Find common prefix length
  local common_length=0
  local min_length=$((${#target_parts[@]} < ${#current_parts[@]} ? ${#target_parts[@]} : ${#current_parts[@]}))

  for ((i=0; i<min_length; i++)); do
    if [[ "${target_parts[i]}" == "${current_parts[i]}" ]]; then
      ((common_length++))
    else
      break
    fi
  done

  # Calculate distance: steps up from current + steps down to target
  local steps_up=$((${#current_parts[@]} - common_length))
  local steps_down=$((${#target_parts[@]} - common_length))
  local total_distance=$((steps_up + steps_down))

  git_changed_cd_debug "Path distance calculation: common_length=$common_length, steps_up=$steps_up, steps_down=$steps_down, total=$total_distance"

  echo "$total_distance"
}

# Sort repositories by their distance from current working directory
git_changed_cd_sort_repos_by_distance() {
  local -a repos=("$@")
  local -a repo_distances=()

  git_changed_cd_debug "Sorting ${#repos[@]} repositories by distance from $PWD"

  # Calculate distances
  for repo in "${repos[@]}"; do
    local distance
    distance=$(git_changed_cd_calculate_path_distance "$repo")
    repo_distances+=("$distance:$repo")
    git_changed_cd_debug "Repository '$repo' distance: $distance"
  done

  # Sort by distance (numeric sort on the distance part)
  IFS=$'\n' sorted=($(printf "%s\n" "${repo_distances[@]}" | sort -n))
  unset IFS

  # Extract just the repository paths
  local -a sorted_repos=()
  for item in "${sorted[@]}"; do
    local repo_path="${item#*:}"
    sorted_repos+=("$repo_path")
    git_changed_cd_debug "Sorted repository: $repo_path"
  done

  # Output sorted repositories
  printf "%s\n" "${sorted_repos[@]}"
}

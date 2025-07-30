#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

git-changed-cd() {
  local scan_mode="current"  # current, registered, all
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        echo "Usage: git-changed-cd [OPTIONS]"
        echo ""
        echo "Navigate to directories with Git changes."
        echo ""
        echo "OPTIONS:"
        echo "  -h, --help                    Show this help message"
        echo "  --justRegisteredDirectories   Scan only registered repositories"
        echo "  --all                        Scan current repository and all registered repositories"
        echo ""
        echo "ALIASES:"
        echo "  gcd     - git-changed-cd"
        echo "  gcdj    - git-changed-cd --justRegisteredDirectories"
        echo "  gcda    - git-changed-cd --all"
        return 0
        ;;
      --justRegisteredDirectories)
        scan_mode="registered"
        shift
        ;;
      --all)
        scan_mode="all"
        shift
        ;;
      *)
        echo "Error: Unknown option '$1'" >&2
        echo "Use 'git-changed-cd --help' for usage information." >&2
        return 1
        ;;
    esac
  done

  git_changed_cd_debug "Starting git-changed-cd function with scan_mode=$scan_mode"

  # Determine which repositories to scan
  local repos_to_scan=()
  
  case $scan_mode in
    "current")
      # Get current repo root if we're in one
      local current_repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
      if [[ -z $current_repo_root ]]; then
        echo "Error: Not inside a Git repository." >&2
        return 1
      fi
      repos_to_scan=("$current_repo_root")
      git_changed_cd_debug "Scanning current repository: $current_repo_root"
      ;;
    "registered")
      # Initialize registry and get registered repos
      git_changed_cd_registry_init
      local registry_count=$(git_changed_cd_registry_count)
      if [[ $registry_count -eq 0 ]]; then
        echo "No registered repositories found."
        echo "Use 'git-changed-cd-add-repo <path>' to register repositories."
        return 0
      fi
      
      # Get registered repos and sort by distance
      local -a unsorted_repos=()
      while IFS= read -r repo; do
        unsorted_repos+=("$repo")
      done < <(git_changed_cd_registry_get_repos)
      
      # Sort by distance from current directory
      while IFS= read -r repo; do
        repos_to_scan+=("$repo")
      done < <(git_changed_cd_sort_repos_by_distance "${unsorted_repos[@]}")
      
      git_changed_cd_debug "Scanning ${#repos_to_scan[@]} registered repositories (sorted by distance)"
      ;;
    "all")
      # Get current repo if we're in one
      local current_repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
      local -a all_repos=()
      
      if [[ -n $current_repo_root ]]; then
        all_repos=("$current_repo_root")
        git_changed_cd_debug "Added current repository: $current_repo_root"
      fi
      
      # Add registered repos (avoid duplicates)
      git_changed_cd_registry_init
      while IFS= read -r repo; do
        local already_added=false
        for existing_repo in "${all_repos[@]}"; do
          if [[ "$existing_repo" == "$repo" ]]; then
            already_added=true
            break
          fi
        done
        if [[ $already_added == false ]]; then
          all_repos+=("$repo")
          git_changed_cd_debug "Added registered repository: $repo"
        fi
      done < <(git_changed_cd_registry_get_repos)
      
      if [[ ${#all_repos[@]} -eq 0 ]]; then
        echo "Error: Not inside a Git repository and no registered repositories found." >&2
        echo "Use 'git-changed-cd-add-repo <path>' to register repositories." >&2
        return 1
      fi
      
      # Sort all repos by distance from current directory
      while IFS= read -r repo; do
        repos_to_scan+=("$repo")
      done < <(git_changed_cd_sort_repos_by_distance "${all_repos[@]}")
      
      git_changed_cd_debug "Scanning ${#repos_to_scan[@]} total repositories (current + registered, sorted by distance)"
      ;;
  esac

  # Collect all directories with changes from all repositories
  local all_relevant_dirs=()
  local repo_dir_mapping=()  # Format: "dir_index:repo_path"
  
  for repo_root in "${repos_to_scan[@]}"; do
    git_changed_cd_debug "Processing repository: $repo_root"
    
    # Skip if repo doesn't exist or isn't a git repo
    if [[ ! -d "$repo_root" ]] || ! git -C "$repo_root" rev-parse --git-dir >/dev/null 2>&1; then
      git_changed_cd_debug "Skipping invalid repository: $repo_root"
      continue
    fi
    
    # Get changes for this repository
    local repo_dirs
    repo_dirs=$(git_changed_cd_get_repo_directories "$repo_root")
    if [[ $? -ne 0 ]] || [[ -z "$repo_dirs" ]]; then
      git_changed_cd_debug "No changes found in repository: $repo_root"
      continue
    fi
    
    # Add directories to the global list with repo mapping
    while IFS= read -r dir; do
      local full_dir_path
      if [[ "$dir" == "." ]]; then
        full_dir_path="$repo_root"
      else
        full_dir_path="$repo_root/$dir"
      fi
      
      all_relevant_dirs+=("$full_dir_path")
      repo_dir_mapping+=("$((${#all_relevant_dirs[@]} - 1)):$repo_root")
      git_changed_cd_debug "Added directory: $full_dir_path (from repo: $repo_root)"
    done <<<"$repo_dirs"
  done

  # Check if we found any directories
  if [[ ${#all_relevant_dirs[@]} -eq 0 ]]; then
    case $scan_mode in
      "current")
        echo "No changes detected (staged, unstaged, or untracked)."
        ;;
      "registered")
        echo "No changes detected in any registered repositories."
        ;;
      "all")
        echo "No changes detected in current or registered repositories."
        ;;
    esac
    return 0
  fi

  # Display directories with numbers
  git_changed_cd_debug "Displaying directory selection menu with ${#all_relevant_dirs[@]} directories"
  echo "Directories with changes:"
  
  local i
  for i in "${!all_relevant_dirs[@]}"; do
    local display_dir="${all_relevant_dirs[i]}"
    
    # Find which repo this directory belongs to
    local repo_for_dir=""
    for mapping in "${repo_dir_mapping[@]}"; do
      local dir_index="${mapping%%:*}"
      local repo_path="${mapping#*:}"
      if [[ "$dir_index" == "$i" ]]; then
        repo_for_dir="$repo_path"
        break
      fi
    done
    
    # Format display string
    if [[ "$scan_mode" != "current" ]]; then
      # Show repo name for multi-repo modes
      local repo_name=$(basename "$repo_for_dir")
      if [[ "$display_dir" == "$repo_for_dir" ]]; then
        display_dir="[$repo_name] <repo root>"
      else
        local rel_dir="${display_dir#$repo_for_dir/}"
        display_dir="[$repo_name] $rel_dir"
      fi
    else
      # Single repo mode - show as before
      if [[ "$display_dir" == "$repo_for_dir" ]]; then
        display_dir="<repo root>"
      else
        display_dir="${display_dir#$repo_for_dir/}"
      fi
    fi
    
    printf "%d: %s\n" "$((i + 1))" "$display_dir"
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
    return 1
  fi

  # Handle cancellation
  if ((selection == 0)); then
    git_changed_cd_debug "User cancelled operation"
    echo "Operation cancelled."
    return 0
  fi

  # Validate selection range
  if ((selection >= 1 && selection <= ${#all_relevant_dirs[@]})); then
    local target_dir_abs="${all_relevant_dirs[selection - 1]}"
    git_changed_cd_debug "Selected directory (absolute): '$target_dir_abs'"

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
    return 1
  fi
}

# Define the aliases
alias gcd='git-changed-cd'
alias gcdj='git-changed-cd --justRegisteredDirectories'
alias gcda='git-changed-cd --all'
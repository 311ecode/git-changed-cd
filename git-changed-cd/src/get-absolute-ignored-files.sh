#!/usr/bin/env bash
function get-absolute-ignored-files {
  local target_path="$1"
  local git_root

  # Debug output if DEBUG is set
  if [[ -n $DEBUG ]]; then
    echo "Debug: get-absolute-ignored-files called with args: $*" >&2
  fi

  if [[ -z $target_path ]]; then
    target_path="$(pwd)"
  fi

  if [[ ! -e $target_path ]]; then
    echo "Error: '$target_path' does not exist." >&2
    return 1
  fi

  target_path=$(realpath "$target_path" 2>/dev/null ||
    readlink -f "$target_path" 2>/dev/null)
  if [[ -z $target_path ]]; then
    echo "Error: Failed to resolve absolute path for '$1'." >&2
    return 1
  fi

  if [[ -n $DEBUG ]]; then
    echo "Debug: Resolved target_path=$target_path" >&2
  fi

  if [[ -d $target_path ]]; then
    git_root=$(git -C "$target_path" rev-parse \
      --show-toplevel 2>/dev/null)
  else
    git_root=$(git -C "$(dirname "$target_path")" rev-parse \
      --show-toplevel 2>/dev/null)
  fi

  if [[ -z $git_root ]]; then
    echo "Error: '$target_path' is not part of a Git repository." >&2
    return 1
  fi

  if [[ -n $DEBUG ]]; then
    echo "Debug: Git repository root=$git_root" >&2
  fi

  local ignored_items
  ignored_items=$(git -C "$git_root" status --porcelain --ignored \
    2>/dev/null | grep '^!!' | cut -c4-)
  if [[ -z $ignored_items ]]; then
    if [[ -n $DEBUG ]]; then
      echo "Debug: No ignored items found in the repository." >&2
    fi
    return 0
  fi

  if [[ -n $DEBUG ]]; then
    echo "Debug: Found ignored items: $ignored_items" >&2
  fi

  while IFS= read -r item; do
    [[ -z $item ]] && continue
    local full_path="$git_root/$item"

    if [[ -n $DEBUG ]]; then
      echo "Debug: Processing item=$full_path" >&2
    fi

    if [[ -d $full_path ]]; then
      find "$full_path" -type f \
        -exec realpath {} \; 2>/dev/null ||
        find "$full_path" -type f \
          -exec readlink -f {} \; 2>/dev/null
    elif [[ -f $full_path ]]; then
      realpath "$full_path" 2>/dev/null ||
        readlink -f "$full_path" 2>/dev/null
    fi
  done <<<"$ignored_items"
}

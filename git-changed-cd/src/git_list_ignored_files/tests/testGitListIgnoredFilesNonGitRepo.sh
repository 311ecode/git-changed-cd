#!/usr/bin/env bash
testGitListIgnoredFilesNonGitRepo() {
    echo "🚫 Testing path outside Git repository"

    # Create temp dir without Git
    local temp_dir=$(mktemp -d)
    local temp_output=$(mktemp)
    git_list_ignored_files "$temp_dir" 2>"$temp_output" >/dev/null

    # Check error message
    if grep -q "Error: '$temp_dir' is not part of a Git repository" "$temp_output"; then
      echo "✅ SUCCESS: Correctly handled non-Git repository"
      rm -rf "$temp_dir"
      rm -f "$temp_output"
      return 0
    else
      echo "❌ ERROR: Expected error message for non-Git repository"
      rm -rf "$temp_dir"
      rm -f "$temp_output"
      return 1
    fi
  }
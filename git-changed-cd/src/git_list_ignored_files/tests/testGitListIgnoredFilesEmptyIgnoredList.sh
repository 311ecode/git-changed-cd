#!/usr/bin/env bash
testGitListIgnoredFilesEmptyIgnoredList() {
    echo "🧨 Testing repository with no ignored files"

    # Setup temporary Git repo with no ignored files
    local temp_dir=$(mktemp -d)
    git init "$temp_dir" >/dev/null 2>&1
    touch "$temp_dir/regular_file.txt"

    # Run the command, strip header
    local result=$(git_list_ignored_files "$temp_dir" 2>/dev/null | grep -v "Listing ignored files")

    # Verify empty output
    if [[ -z "$result" ]]; then
      echo "✅ SUCCESS: Correctly returned empty list for no ignored files"
      rm -rf "$temp_dir"
      return 0
    else
      echo "❌ ERROR: Expected empty output, got '$result'"
      rm -rf "$temp_dir"
      return 1
    fi
  }
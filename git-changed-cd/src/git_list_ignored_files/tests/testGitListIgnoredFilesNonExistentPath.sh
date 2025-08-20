#!/usr/bin/env bash
testGitListIgnoredFilesNonExistentPath() {
    echo "⚠️ Testing non-existent path"

    # Run with invalid path
    local temp_output=$(mktemp)
    git_list_ignored_files "/non/existent/path" 2>"$temp_output" >/dev/null

    # Check error message
    if grep -q "Error: '/non/existent/path' does not exist" "$temp_output"; then
      echo "✅ SUCCESS: Correctly handled non-existent path"
      rm -f "$temp_output"
      return 0
    else
      echo "❌ ERROR: Expected error message for non-existent path"
      rm -f "$temp_output"
      return 1
    fi
  }
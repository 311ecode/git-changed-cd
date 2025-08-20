#!/usr/bin/env bash
testGitListIgnoredFilesCachedResults() {
    echo "🔄 Testing cached results"

    # Setup temporary Git repo
    local temp_dir=$(mktemp -d)
    git init "$temp_dir" >/dev/null 2>&1
    echo "node_modules/" > "$temp_dir/.gitignore"
    mkdir -p "$temp_dir/node_modules"
    touch "$temp_dir/node_modules/ignore_me.js"

    # First run to create cache
    local first_result=$(git_list_ignored_files "$temp_dir" 2>/dev/null)

    # Second run to use cache
    local second_result=$(git_list_ignored_files "$temp_dir" 2>/dev/null)

    # Verify cache usage
    if [[ "$first_result" == "$second_result" && "$second_result" == *"$temp_dir/node_modules/ignore_me.js"* ]]; then
      echo "✅ SUCCESS: Cache correctly used with identical results"
      rm -rf "$temp_dir"
      return 0
    else
      echo "❌ ERROR: Expected cached results to match, got first='$first_result', second='$second_result'"
      rm -rf "$temp_dir"
      return 1
    fi
  }
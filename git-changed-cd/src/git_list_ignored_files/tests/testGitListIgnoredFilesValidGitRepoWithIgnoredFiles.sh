#!/usr/bin/env bash
testGitListIgnoredFilesValidGitRepoWithIgnoredFiles() {
    echo "🧪 Testing valid Git repository with ignored files"

    # Setup temporary Git repo
    local temp_dir=$(mktemp -d)
    git init "$temp_dir" >/dev/null 2>&1
    echo "node_modules/" > "$temp_dir/.gitignore"
    mkdir -p "$temp_dir/node_modules"
    touch "$temp_dir/node_modules/ignore_me.js"
    touch "$temp_dir/regular_file.txt"

    # Run the command
    local result=$(git_list_ignored_files "$temp_dir" 2>/dev/null)

    # Verify output
    if [[ "$result" == *"$temp_dir/node_modules/ignore_me.js"* ]]; then
      echo "✅ SUCCESS: Correctly listed ignored file"
      rm -rf "$temp_dir"
      return 0
    else
      echo "❌ ERROR: Expected ignored file '$temp_dir/node_modules/ignore_me.js', got '$result'"
      rm -rf "$temp_dir"
      return 1
    fi
  }
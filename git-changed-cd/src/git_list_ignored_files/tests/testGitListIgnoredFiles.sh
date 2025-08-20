#!/usr/bin/env bash
testGitListIgnoredFiles() {
  export LC_NUMERIC=C  # 🔢 Ensure consistent numeric formatting

  # Nested test functions for clear error paths 🧩
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

  # Test function registry 📋
  local test_functions=(
    "testGitListIgnoredFilesValidGitRepoWithIgnoredFiles"
    "testGitListIgnoredFilesNonExistentPath"
    "testGitListIgnoredFilesNonGitRepo"
    "testGitListIgnoredFilesCachedResults"
    "testGitListIgnoredFilesEmptyIgnoredList"
  )

  local ignored_tests=()  # 🚫 Add tests to skip if needed

  # Run tests with consistent numeric formatting
  bashTestRunner test_functions ignored_tests
  return $?
}
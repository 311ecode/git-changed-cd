#!/usr/bin/env bash
testNotInGitRepo() {
    echo "🧪 Testing behavior outside a Git repository"
    # Create a non-Git directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || {
      echo "❌ ERROR: Failed to cd to temp dir '$temp_dir'"
      return 1
    }
    local temp_output=$(mktemp)
    git-changed-cd >"$temp_output" 2>&1
    local result=$?
    if [[ $result -ne 1 ]] || ! grep -q "Error: Not inside a Git repository." "$temp_output"; then
      echo "❌ ERROR: Expected exit code 1 and 'Not inside a Git repository' message, got exit code $result"
      cat "$temp_output"
      rm -f "$temp_output"
      cd "$saved_pwd" || return 1
      return 1
    fi
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    echo "✅ SUCCESS: Correctly handled non-Git repository"
    return 0
  }
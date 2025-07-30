#!/usr/bin/env bash
testMissingTargetDirectory() {
    echo "🧪 Testing missing target directory"
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || {
      echo "❌ ERROR: Failed to cd to temp dir '$temp_dir'"
      return 1
    }
    git init -b main >/dev/null
    mkdir src
    echo "test" > src/file.txt
    git add src/file.txt
    rm -rf src
    local temp_output=$(mktemp)
    unset DEBUG # Ensure no debug output interferes
    git-changed-cd < <(echo "2") >"$temp_output" 2>&1
    local result=$?
    if [[ $result -ne 1 ]] || ! grep -q "Error: Selected directory .*src.* seems to not exist." "$temp_output" || [[ "$(pwd)" != "$temp_dir" ]]; then
      echo "❌ ERROR: Expected exit code 1, 'Selected directory ... seems to not exist' message, and no directory change, got exit code $result, pwd $(pwd)"
      cat "$temp_output"
      rm -f "$temp_output"
      cd "$saved_pwd" || return 1
      return 1
    fi
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    echo "✅ SUCCESS: Correctly handled missing target directory"
    return 0
}

#!/usr/bin/env bash
testUntrackedFileNavigation() {
    echo "🧪 Testing navigation to directory with untracked file"
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || {
      echo "❌ ERROR: Failed to cd to temp dir '$temp_dir'"
      return 1
    }
    git init -b main >/dev/null
    mkdir -p tests/unit
    echo "test" > tests/unit/untracked.txt
    local temp_output=$(mktemp)
    git-changed-cd < <(echo "3") >"$temp_output" 2>&1
    local result=$?
    if [[ $result -ne 0 ]] || ! grep -q "1: <repo root>" "$temp_output" || ! grep -q "3: tests/unit" "$temp_output" || ! grep -q "Changing directory to: $temp_dir/tests/unit" "$temp_output" || [[ "$(pwd)" != "$temp_dir/tests/unit" ]]; then
      echo "❌ ERROR: Expected exit code 0, tests/unit in menu, navigation to tests/unit, got exit code $result, pwd $(pwd)"
      cat "$temp_output"
      rm -f "$temp_output"
      cd "$saved_pwd" || return 1
      return 1
    fi
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    echo "✅ SUCCESS: Correctly navigated to directory with untracked file"
    return 0
}

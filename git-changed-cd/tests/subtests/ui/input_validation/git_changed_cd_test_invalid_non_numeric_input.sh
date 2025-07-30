git_changed_cd_test_invalid_non_numeric_input() {
  echo "🧪 Testing invalid non-numeric input"
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || {
    echo "❌ ERROR: Failed to cd to temp dir '$temp_dir'"
    return 1
  }
  git init -b main >/dev/null
  touch file.txt
  local temp_output=$(mktemp)
  git-changed-cd < <(echo "abc") >"$temp_output" 2>&1
  local result=$?
  if [[ $result -ne 1 ]] || ! grep -q "Invalid input: Not a number." "$temp_output" || [[ "$(pwd)" != "$temp_dir" ]]; then
    echo "❌ ERROR: Expected exit code 1, 'Invalid input: Not a number' message, and no directory change, got exit code $result, pwd $(pwd)"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi
  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly handled non-numeric input"
  return 0
}

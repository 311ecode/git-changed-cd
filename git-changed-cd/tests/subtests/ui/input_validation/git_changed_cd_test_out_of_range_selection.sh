git_changed_cd_test_out_of_range_selection() {
  echo "🧪 Testing out-of-range selection"
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || {
    echo "❌ ERROR: Failed to cd to temp dir '$temp_dir'"
    return 1
  }
  git init -b main >/dev/null
  touch file.txt
  local temp_output=$(mktemp)
  git-changed-cd < <(echo "99") >"$temp_output" 2>&1
  local result=$?
  if [[ $result -ne 1 ]] || ! grep -q "Invalid selection number: 99" "$temp_output" || [[ "$(pwd)" != "$temp_dir" ]]; then
    echo "❌ ERROR: Expected exit code 1, 'Invalid selection number' message, and no directory change, got exit code $result, pwd $(pwd)"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi
  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly handled out-of-range selection"
  return 0
}

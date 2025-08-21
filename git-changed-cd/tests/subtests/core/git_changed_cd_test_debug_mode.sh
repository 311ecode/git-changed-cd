git_changed_cd_test_debug_mode() {
  echo "🧪 Testing debug mode with DEBUG=1"
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || {
    echo "❌ ERROR: Failed to cd to temp dir '$temp_dir'"
    return 1
  }
  git init -b main >/dev/null
  touch file.txt
  export DEBUG=1
  local temp_output=$(mktemp)
  git-changed-cd < <(echo "0") >"$temp_output" 2>&1
  local result=$?
  if [[ $result -ne 0 ]] || ! grep -F -q "DEBUG[git-changed-cd]: Starting git-changed-cd function" "$temp_output" || ! grep -F -q "DEBUG[git-changed-cd]: Scanning current repository: $temp_dir" "$temp_output" || ! grep -q "Operation cancelled." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 0, debug messages, and 'Operation cancelled', got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    unset DEBUG
    cd "$saved_pwd" || return 1
    return 1
  fi
  rm -f "$temp_output"
  unset DEBUG
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly output debug information"
  return 0
}

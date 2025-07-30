git_changed_cd_test_unstaged_file_navigation() {
  echo "🧪 Testing navigation to directory with unstaged file"
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || {
    echo "❌ ERROR: Failed to cd to temp dir '$temp_dir'"
    return 1
  }
  git init -b main >/dev/null
  mkdir -p src/utils
  echo "test" >src/utils/file.txt
  local temp_output=$(mktemp)
  git-changed-cd < <(echo "3") >"$temp_output" 2>&1
  local result=$?
  if [[ $result -ne 0 ]] || ! grep -q "Changing directory to: $temp_dir/src/utils" "$temp_output" || [[ "$(pwd)" != "$temp_dir/src/utils" ]]; then
    echo "❌ ERROR: Expected exit code 0, navigation to src/utils, and correct pwd, got exit code $result, pwd $(pwd)"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi
  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly navigated to directory with unstaged file"
  return 0
}

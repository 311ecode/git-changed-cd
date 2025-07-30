git_changed_cd_test_clean_repo() {
  echo "🧪 Testing clean repository with no changes"
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || {
    echo "❌ ERROR: Failed to cd to temp dir '$temp_dir'"
    return 1
  }
  git init -b main >/dev/null
  local temp_output=$(mktemp)
  git-changed-cd >"$temp_output" 2>&1
  local result=$?
  if [[ $result -ne 0 ]] || ! grep -q "No changes detected (staged, unstaged, or untracked)." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 0 and 'No changes detected' message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi
  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly handled clean repository"
  return 0
}

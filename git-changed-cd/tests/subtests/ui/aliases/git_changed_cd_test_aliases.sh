git_changed_cd_test_aliases() {
  echo "🧪 Testing new aliases (gcdj, gcda)"
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || return 1
  git init -b main >/dev/null
  touch file.txt

  # Clear registry
  unset GIT_CHANGED_CD_REGISTERED_REPOS

  # Test gcdj alias
  local temp_output=$(mktemp)
  gcdj >"$temp_output" 2>&1
  local result1=$?

  if [[ $result1 -ne 0 ]] || ! grep -q "No registered repositories found." "$temp_output"; then
    echo "❌ ERROR: gcdj alias didn't work correctly, got exit code $result1"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Test gcda alias
  gcda < <(echo "0") >"$temp_output" 2>&1
  local result2=$?

  if [[ $result2 -ne 0 ]] || ! grep -q "Directories with changes:" "$temp_output"; then
    echo "❌ ERROR: gcda alias didn't work correctly, got exit code $result2"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Both aliases work correctly"
  return 0
}

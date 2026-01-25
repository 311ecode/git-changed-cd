git_changed_cd_test_current_repo_display() {
  echo "🧪 Testing current repository display when not registered"
  local temp_dir=$(mktemp -d)
  local registered_repo="$temp_dir/registered"
  local current_repo="$temp_dir/current_unregistered"

  # Create registered repo
  mkdir -p "$registered_repo"
  cd "$registered_repo" || return 1
  git init -b main >/dev/null
  echo "registered" >registered_file.txt

  # Create current repo (not registered)
  mkdir -p "$current_repo/src/utils"
  cd "$current_repo" || return 1
  git init -b main >/dev/null
  echo "current" >src/utils/current_file.txt

  # Clear registry and add only the registered repo
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$registered_repo" >/dev/null 2>&1

  # Test default gcd behavior (should show current repo even though not registered)
  local temp_output=$(mktemp)
  git-changed-cd < <(echo "0") >"$temp_output" 2>&1
  local result=$?

  # Should show directories from current repo without [repo-name] prefix
  if [[ $result -ne 0 ]] || ! grep -q "1: <repo root>" "$temp_output" || ! grep -q "2: src" "$temp_output" || ! grep -q "3: src/utils" "$temp_output"; then
    echo "❌ ERROR: Expected to see current repo directories, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Should NOT show [current_unregistered] prefix since it's current mode
  if grep -q '\[current_unregistered\]' "$temp_output"; then
    echo "❌ ERROR: Should not show repo name prefix in current mode"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Current repo displayed correctly without prefix"
  return 0
}

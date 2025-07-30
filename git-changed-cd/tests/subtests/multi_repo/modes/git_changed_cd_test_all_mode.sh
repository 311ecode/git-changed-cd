git_changed_cd_test_all_mode() {
  echo "🧪 Testing --all mode"
  local temp_dir=$(mktemp -d)
  local repo1_dir="$temp_dir/repo1"
  local current_repo="$temp_dir/current"
  
  # Create registered repo
  mkdir -p "$repo1_dir"
  cd "$repo1_dir" || return 1
  git init -b main >/dev/null
  echo "test1" > file1.txt
  
  # Create current repo
  mkdir -p "$current_repo"
  cd "$current_repo" || return 1
  git init -b main >/dev/null
  echo "current" > current.txt
  
  # Clear registry and add repo1
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$repo1_dir" >/dev/null 2>&1
  
  local temp_output=$(mktemp)
  git-changed-cd --all < <(echo "0") >"$temp_output" 2>&1
  local result=$?
  
  if [[ $result -ne 0 ]] || ! grep -q "\\[repo1\\]" "$temp_output" || ! grep -q "\\[current\\]" "$temp_output"; then
    echo "❌ ERROR: Expected to see both current and registered repos, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi
  
  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly showed both current and registered repositories"
  return 0
}
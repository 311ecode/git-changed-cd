git_changed_cd_test_just_registered_directories() {
  echo "🧪 Testing --justRegisteredDirectories mode"
  local temp_dir=$(mktemp -d)
  local repo1_dir="$temp_dir/repo1"
  local repo2_dir="$temp_dir/repo2"

  # Create two repos with changes
  mkdir -p "$repo1_dir" "$repo2_dir"

  cd "$repo1_dir" || return 1
  git init -b main >/dev/null
  mkdir src
  echo "test1" >src/file1.txt

  cd "$repo2_dir" || return 1
  git init -b main >/dev/null
  mkdir tests
  echo "test2" >tests/file2.txt

  # Clear registry and add both repos
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$repo1_dir" >/dev/null 2>&1
  git-changed-cd-add-repo "$repo2_dir" >/dev/null 2>&1

  # Create a third repo (current) that's not registered
  local current_repo="$temp_dir/current"
  mkdir -p "$current_repo"
  cd "$current_repo" || return 1
  git init -b main >/dev/null
  echo "current" >current.txt

  local temp_output=$(mktemp)
  git-changed-cd --justRegisteredDirectories < <(echo "0") >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 0 ]] || ! grep -q '\[repo1\]' "$temp_output" || ! grep -q '\[repo2\]' "$temp_output" || grep -q "current" "$temp_output"; then
    echo "❌ ERROR: Expected to see registered repos but not current repo, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly showed only registered repositories"
  return 0
}

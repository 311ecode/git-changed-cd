git_changed_cd_test_list_repos_alias() {
  echo "🧪 Testing list repositories alias (gcd-list)"
  local temp_dir=$(mktemp -d)
  local repo_dir="$temp_dir/test_repo"
  mkdir -p "$repo_dir"
  cd "$repo_dir" || {
    echo "❌ ERROR: Failed to cd to repo dir '$repo_dir'"
    return 1
  }
  git init -b main >/dev/null

  # Clear registry and add repo
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$repo_dir" >/dev/null 2>&1

  local temp_output=$(mktemp)
  gcd-list >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 0 ]] || ! grep -q "Registered repositories (1):" "$temp_output" || ! grep -q "1: $repo_dir" "$temp_output"; then
    echo "❌ ERROR: gcd-list alias didn't work correctly, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: gcd-list alias works correctly"
  return 0
}

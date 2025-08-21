git_changed_cd_test_list_repos_multiple() {
  echo "🧪 Testing list repositories with multiple repositories"
  local temp_dir=$(mktemp -d)
  local repo1_dir="$temp_dir/repo1"
  local repo2_dir="$temp_dir/repo2"
  local repo3_dir="$temp_dir/repo3"

  # Create three repos
  mkdir -p "$repo1_dir" "$repo2_dir" "$repo3_dir"

  cd "$repo1_dir" && git init -b main >/dev/null
  cd "$repo2_dir" && git init -b main >/dev/null
  cd "$repo3_dir" && git init -b main >/dev/null

  # Clear registry and add all three repos
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$repo1_dir" >/dev/null 2>&1
  git-changed-cd-add-repo "$repo2_dir" >/dev/null 2>&1
  git-changed-cd-add-repo "$repo3_dir" >/dev/null 2>&1

  local temp_output=$(mktemp)
  git-changed-cd-list-repos >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 0 ]] || ! grep -q "Registered repositories (3):" "$temp_output" || ! grep -q "1: $repo1_dir" "$temp_output" || ! grep -q "2: $repo2_dir" "$temp_output" || ! grep -q "3: $repo3_dir" "$temp_output"; then
    echo "❌ ERROR: Expected exit code 0, count (3), and all repo paths, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly listed multiple repositories"
  return 0
}

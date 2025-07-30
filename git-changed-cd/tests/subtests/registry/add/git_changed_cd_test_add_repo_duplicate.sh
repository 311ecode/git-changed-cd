git_changed_cd_test_add_repo_duplicate() {
  echo "🧪 Testing duplicate repository addition"
  local temp_dir=$(mktemp -d)
  local repo_dir="$temp_dir/test_repo"
  mkdir -p "$repo_dir"
  cd "$repo_dir" || {
    echo "❌ ERROR: Failed to cd to repo dir '$repo_dir'"
    return 1
  }
  git init -b main >/dev/null
  
  # Clear registry and add repo first time
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$repo_dir" >/dev/null 2>&1
  
  # Try to add same repo again
  local temp_output=$(mktemp)
  git-changed-cd-add-repo "$repo_dir" >"$temp_output" 2>&1
  local result=$?
  
  if [[ $result -ne 0 ]] || ! grep -q "Repository '$repo_dir' is already registered." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 0 and 'already registered' message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi
  
  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly handled duplicate repository addition"
  return 0
}
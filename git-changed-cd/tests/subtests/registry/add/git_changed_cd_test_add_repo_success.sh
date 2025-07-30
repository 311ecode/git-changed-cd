git_changed_cd_test_add_repo_success() {
  echo "🧪 Testing successful repository addition"
  local temp_dir=$(mktemp -d)
  local repo_dir="$temp_dir/test_repo"
  mkdir -p "$repo_dir"
  cd "$repo_dir" || {
    echo "❌ ERROR: Failed to cd to repo dir '$repo_dir'"
    return 1
  }
  git init -b main >/dev/null
  
  # Clear any existing registry
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  
  local temp_output=$(mktemp)
  git-changed-cd-add-repo "$repo_dir" >"$temp_output" 2>&1
  local result=$?
  
  if [[ $result -ne 0 ]] || ! grep -q "Added repository: $repo_dir" "$temp_output" || [[ -z "${GIT_CHANGED_CD_REGISTERED_REPOS:-}" ]]; then
    echo "❌ ERROR: Expected exit code 0, success message, and registry to be set, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi
  
  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Successfully added repository to registry"
  return 0
}
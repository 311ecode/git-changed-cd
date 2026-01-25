git_changed_cd_test_remove_repo_success() {
  echo "🧪 Testing successful repository removal"
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

  # Remove repo
  local temp_output=$(mktemp)
  git-changed-cd-remove-repo "$repo_dir" >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 0 ]] || ! grep -q "Removed repository: $repo_dir" "$temp_output" || [[ -n ${GIT_CHANGED_CD_REGISTERED_REPOS:-} ]]; then
    echo "❌ ERROR: Expected exit code 0, success message, and empty registry, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Successfully removed repository from registry"
  return 0
}

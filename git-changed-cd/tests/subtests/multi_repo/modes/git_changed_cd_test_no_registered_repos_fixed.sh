git_changed_cd_test_no_registered_repos() {
  echo "🧪 Testing --justRegisteredDirectories with no registered repos"

  # Save current registry state
  local saved_registry="${GIT_CHANGED_CD_REGISTERED_REPOS:-}"

  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || return 1
  git init -b main >/dev/null

  # Clear registry
  unset GIT_CHANGED_CD_REGISTERED_REPOS

  local temp_output=$(mktemp)
  git-changed-cd --justRegisteredDirectories >"$temp_output" 2>&1
  local result=$?

  # Restore registry state
  if [[ -n "$saved_registry" ]]; then
    export GIT_CHANGED_CD_REGISTERED_REPOS="$saved_registry"
  else
    unset GIT_CHANGED_CD_REGISTERED_REPOS
  fi

  if [[ $result -ne 0 ]] || ! grep -q "No registered repositories found." "$temp_output" || ! grep -q "Use 'git-changed-cd-add-repo <path>' to register repositories." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 0 and helpful message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Correctly handled no registered repositories"
  return 0
}

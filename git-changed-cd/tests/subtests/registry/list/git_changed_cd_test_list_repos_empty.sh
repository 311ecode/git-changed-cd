git_changed_cd_test_list_repos_empty() {
  echo "🧪 Testing list repositories with empty registry"
  
  # Clear registry
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  
  local temp_output=$(mktemp)
  git-changed-cd-list-repos >"$temp_output" 2>&1
  local result=$?
  
  if [[ $result -ne 0 ]] || ! grep -q "No registered repositories found." "$temp_output" || ! grep -q "Use 'git-changed-cd-add-repo <path>' to register repositories." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 0 and helpful message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi
  
  rm -f "$temp_output"
  echo "✅ SUCCESS: Correctly handled empty registry"
  return 0
}

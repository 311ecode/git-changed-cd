git_changed_cd_test_remove_repo_nonexistent() {
  echo "🧪 Testing removal of nonexistent repository"
  local nonexistent_path="/tmp/definitely_does_not_exist_$(date +%s)"
  
  # Set up registry with the nonexistent path
  export GIT_CHANGED_CD_REGISTERED_REPOS="$nonexistent_path"
  
  local temp_output=$(mktemp)
  git-changed-cd-remove-repo "$nonexistent_path" >"$temp_output" 2>&1
  local result=$?
  
  if [[ $result -ne 0 ]] || ! grep -q "Removed repository: $nonexistent_path" "$temp_output" || [[ -n "${GIT_CHANGED_CD_REGISTERED_REPOS:-}" ]]; then
    echo "❌ ERROR: Expected exit code 0, success message, and empty registry, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi
  
  rm -f "$temp_output"
  echo "✅ SUCCESS: Successfully removed nonexistent repository from registry"
  return 0
}
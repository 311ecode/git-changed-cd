git_changed_cd_test_list_repos_invalid_parameter() {
  echo "🧪 Testing list repositories with invalid parameter"
  
  local temp_output=$(mktemp)
  git-changed-cd-list-repos --invalid-option >"$temp_output" 2>&1
  local result=$?
  
  if [[ $result -ne 1 ]] || ! grep -q "Error: Unknown option '--invalid-option'" "$temp_output" || ! grep -q "Use 'git-changed-cd-list-repos --help' for usage information." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 1 and error message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi
  
  rm -f "$temp_output"
  echo "✅ SUCCESS: Correctly handled invalid parameter"
  return 0
}

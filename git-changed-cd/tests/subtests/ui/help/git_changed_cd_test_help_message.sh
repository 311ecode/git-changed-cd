git_changed_cd_test_help_message() {
  echo "🧪 Testing help message"
  local temp_output=$(mktemp)
  git-changed-cd --help >"$temp_output" 2>&1
  local result=$?
  
  if [[ $result -ne 0 ]] || ! grep -q "Usage: git-changed-cd \\[OPTIONS\\]" "$temp_output" || ! grep -q "gcdj    - git-changed-cd --justRegisteredDirectories" "$temp_output" || ! grep -q "gcda    - git-changed-cd --all" "$temp_output"; then
    echo "❌ ERROR: Expected exit code 0 and proper help message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi
  
  rm -f "$temp_output"
  echo "✅ SUCCESS: Help message displayed correctly"
  return 0
}
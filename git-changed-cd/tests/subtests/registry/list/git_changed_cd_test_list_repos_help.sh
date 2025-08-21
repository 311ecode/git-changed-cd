git_changed_cd_test_list_repos_help() {
  echo "🧪 Testing list repositories help message"

  local temp_output=$(mktemp)
  git-changed-cd-list-repos --help >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 0 ]] || ! grep -q "Usage: git-changed-cd-list-repos \\[OPTIONS\\]" "$temp_output" || ! grep -q "List all registered repositories." "$temp_output" || ! grep -q "gcd-list     - git-changed-cd-list-repos" "$temp_output"; then
    echo "❌ ERROR: Expected exit code 0 and proper help message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi

  rm -f "$temp_output"
  echo "✅ SUCCESS: Help message displayed correctly"
  return 0
}

git_changed_cd_test_add_repo_no_parameter() {
  echo "🧪 Testing repository addition with no parameter"

  local temp_output=$(mktemp)
  git-changed-cd-add-repo >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 1 ]] || ! grep -q "Error: Repository path is required." "$temp_output" || ! grep -q "Usage: git-changed-cd-add-repo <path>" "$temp_output"; then
    echo "❌ ERROR: Expected exit code 1 and usage message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi

  rm -f "$temp_output"
  echo "✅ SUCCESS: Correctly handled missing parameter"
  return 0
}

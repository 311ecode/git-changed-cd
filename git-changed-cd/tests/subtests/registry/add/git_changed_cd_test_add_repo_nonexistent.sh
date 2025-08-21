git_changed_cd_test_add_repo_nonexistent() {
  echo "🧪 Testing addition of nonexistent repository"
  local nonexistent_path="/tmp/definitely_does_not_exist_$(date +%s)"

  local temp_output=$(mktemp)
  git-changed-cd-add-repo "$nonexistent_path" >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 1 ]] || ! grep -q "Error: Directory '$nonexistent_path' does not exist." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 1 and 'does not exist' message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi

  rm -f "$temp_output"
  echo "✅ SUCCESS: Correctly handled nonexistent directory"
  return 0
}

git_changed_cd_test_add_repo_not_git() {
  echo "🧪 Testing addition of non-git directory"
  local temp_dir=$(mktemp -d)
  local non_git_dir="$temp_dir/not_git"
  mkdir -p "$non_git_dir"

  local temp_output=$(mktemp)
  git-changed-cd-add-repo "$non_git_dir" >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 1 ]] || ! grep -q "Error: '$non_git_dir' is not a Git repository." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 1 and 'not a Git repository' message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi

  rm -f "$temp_output"
  echo "✅ SUCCESS: Correctly handled non-git directory"
  return 0
}

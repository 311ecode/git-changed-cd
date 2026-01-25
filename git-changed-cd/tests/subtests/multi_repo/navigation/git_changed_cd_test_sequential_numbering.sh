git_changed_cd_test_sequential_numbering() {
  echo "🧪 Testing sequential numbering across multiple repos"
  local temp_dir=$(mktemp -d)
  local repo1_dir="$temp_dir/repo1"
  local repo2_dir="$temp_dir/repo2"

  # Create two repos with multiple directories each
  mkdir -p "$repo1_dir/src/utils" "$repo1_dir/tests"
  cd "$repo1_dir" || return 1
  git init -b main >/dev/null
  echo "test1" >src/utils/file1.txt
  echo "test2" >tests/file2.txt

  mkdir -p "$repo2_dir/docs" "$repo2_dir/examples"
  cd "$repo2_dir" || return 1
  git init -b main >/dev/null
  echo "test3" >docs/file3.txt
  echo "test4" >examples/file4.txt

  # Clear registry and add both repos
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$repo1_dir" >/dev/null 2>&1
  git-changed-cd-add-repo "$repo2_dir" >/dev/null 2>&1

  local temp_output=$(mktemp)
  git-changed-cd --justRegisteredDirectories < <(echo "0") >"$temp_output" 2>&1
  local result=$?

  # Should have sequential numbering: repo1 gets 1-5, repo2 gets 6-9 (approximately)
  if [[ $result -ne 0 ]] || ! grep -q "1:" "$temp_output" || ! grep -q "5:" "$temp_output" || ! grep -q "6:" "$temp_output"; then
    echo "❌ ERROR: Expected sequential numbering across repos, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Sequential numbering works correctly across multiple repos"
  return 0
}

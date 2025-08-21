git_changed_cd_test_current_vs_registered_display() {
  echo "🧪 Testing display differences between current and registered repos"
  local temp_dir=$(mktemp -d)
  local repo1="$temp_dir/repo1"
  local repo2="$temp_dir/repo2"

  # Create two repos with identical structure
  mkdir -p "$repo1/src/utils" "$repo2/src/utils"

  cd "$repo1" || return 1
  git init -b main >/dev/null
  echo "repo1" > src/utils/file1.txt

  cd "$repo2" || return 1
  git init -b main >/dev/null
  echo "repo2" > src/utils/file2.txt

  # Clear registry and add repo1
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$repo1" >/dev/null 2>&1

  # Test from repo2 (current, not registered) - default mode
  local temp_output1=$(mktemp)
  git-changed-cd < <(echo "0") >"$temp_output1" 2>&1
  local result1=$?

  # Test registered mode from repo2
  local temp_output2=$(mktemp)
  git-changed-cd --justRegisteredDirectories < <(echo "0") >"$temp_output2" 2>&1
  local result2=$?

  # Test all mode from repo2
  local temp_output3=$(mktemp)
  git-changed-cd --all < <(echo "0") >"$temp_output3" 2>&1
  local result3=$?

  # Verify current mode shows repo2 without prefix
  if [[ $result1 -ne 0 ]] || grep -q "\\[repo2\\]" "$temp_output1" || ! grep -q "src/utils" "$temp_output1"; then
    echo "❌ ERROR: Current mode should show repo2 without prefix"
    echo "=== Current mode output ==="
    cat "$temp_output1"
    rm -f "$temp_output1" "$temp_output2" "$temp_output3"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Verify registered mode shows repo1 with prefix
  if [[ $result2 -ne 0 ]] || ! grep -q "\\[repo1\\]" "$temp_output2" || grep -q "repo2" "$temp_output2"; then
    echo "❌ ERROR: Registered mode should show repo1 with prefix, not repo2"
    echo "=== Registered mode output ==="
    cat "$temp_output2"
    rm -f "$temp_output1" "$temp_output2" "$temp_output3"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Verify all mode shows both repos with prefixes
  if [[ $result3 -ne 0 ]] || ! grep -q "\\[repo1\\]" "$temp_output3" || ! grep -q "\\[repo2\\]" "$temp_output3"; then
    echo "❌ ERROR: All mode should show both repos with prefixes"
    echo "=== All mode output ==="
    cat "$temp_output3"
    rm -f "$temp_output1" "$temp_output2" "$temp_output3"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output1" "$temp_output2" "$temp_output3"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Display differences work correctly across modes"
  return 0
}

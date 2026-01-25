git_changed_cd_test_distance_ordering() {
  echo "🧪 Testing repository ordering by distance from current directory"
  local temp_dir=$(mktemp -d)
  local close_repo="$temp_dir/close"
  local far_repo="$temp_dir/very/far/away"
  local current_dir="$temp_dir/current"

  # Create repositories at different distances
  mkdir -p "$close_repo" "$far_repo" "$current_dir"

  # Close repo (1 level up)
  cd "$close_repo" || return 1
  git init -b main >/dev/null
  echo "close" >close_file.txt

  # Far repo (3 levels up)
  cd "$far_repo" || return 1
  git init -b main >/dev/null
  echo "far" >far_file.txt

  # Current working directory
  cd "$current_dir" || return 1
  git init -b main >/dev/null
  echo "current" >current_file.txt

  # Clear registry and add repos in reverse distance order (far first, then close)
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$far_repo" >/dev/null 2>&1
  git-changed-cd-add-repo "$close_repo" >/dev/null 2>&1

  # Test registered mode - should show close repo first despite being added second
  local temp_output=$(mktemp)
  git-changed-cd --justRegisteredDirectories < <(echo "0") >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 0 ]]; then
    echo "❌ ERROR: Expected successful execution, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Check that close repo appears before far repo in the output
  local close_line=$(grep -n '\[close\]' "$temp_output" | cut -d: -f1)
  local far_line=$(grep -n '\[away\]' "$temp_output" | cut -d: -f1)

  if [[ -z $close_line ]] || [[ -z $far_line ]]; then
    echo "❌ ERROR: Could not find both repositories in output"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  if [[ $close_line -gt $far_line ]]; then
    echo "❌ ERROR: Close repo should appear before far repo. Close line: $close_line, Far line: $far_line"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Repositories ordered correctly by distance"
  return 0
}

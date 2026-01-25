git_changed_cd_test_all_mode_distance_ordering() {
  echo "🧪 Testing --all mode ordering by distance"
  local temp_dir=$(mktemp -d)
  local registered_close="$temp_dir/reg_close"
  local registered_far="$temp_dir/very/deep/reg_far"
  local current_middle="$temp_dir/middle/current"

  # Create repositories at different distances from the current position
  mkdir -p "$registered_close" "$registered_far" "$current_middle"

  # Registered close repo
  cd "$registered_close" || return 1
  git init -b main >/dev/null
  echo "reg_close" >file.txt

  # Registered far repo
  cd "$registered_far" || return 1
  git init -b main >/dev/null
  echo "reg_far" >file.txt

  # Current repo (middle distance)
  cd "$current_middle" || return 1
  git init -b main >/dev/null
  echo "current" >file.txt

  # Register repos in reverse distance order (far first)
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git-changed-cd-add-repo "$registered_far" >/dev/null 2>&1
  git-changed-cd-add-repo "$registered_close" >/dev/null 2>&1

  # Test --all mode from current directory
  local temp_output=$(mktemp)
  git-changed-cd --all < <(echo "0") >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 0 ]]; then
    echo "❌ ERROR: Expected successful execution, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Extract line numbers for each repository
  local current_line=$(grep -n '\[current\]' "$temp_output" | head -1 | cut -d: -f1)
  local close_line=$(grep -n '\[reg_close\]' "$temp_output" | head -1 | cut -d: -f1)
  local far_line=$(grep -n '\[reg_far\]' "$temp_output" | head -1 | cut -d: -f1)

  if [[ -z $current_line ]] || [[ -z $close_line ]] || [[ -z $far_line ]]; then
    echo "❌ ERROR: Could not find all repositories in output"
    echo "Current line: $current_line, Close line: $close_line, Far line: $far_line"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Verify ordering: current < close < far (based on distance from temp_dir/middle/current)
  # Current has distance 0, close has distance 3, far has distance 5
  if [[ $current_line -gt $close_line ]] || [[ $close_line -gt $far_line ]]; then
    echo "❌ ERROR: Incorrect ordering. Expected: current($current_line) < close($close_line) < far($far_line)"
    cat "$temp_output"
    rm -f "$temp_output"
    cd "$saved_pwd" || return 1
    return 1
  fi

  rm -f "$temp_output"
  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: All mode repositories ordered correctly by distance"
  return 0
}

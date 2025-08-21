git_changed_cd_test_invalid_parameter() {
  echo "🧪 Testing invalid parameter for main function"

  local temp_output=$(mktemp)
  git-changed-cd --invalid-option >"$temp_output" 2>&1
  local result=$?

  if [[ $result -ne 1 ]] || ! grep -q "Error: Unknown option '--invalid-option'" "$temp_output" || ! grep -q "Use 'git-changed-cd --help' for usage information." "$temp_output"; then
    echo "❌ ERROR: Expected exit code 1 and error message, got exit code $result"
    cat "$temp_output"
    rm -f "$temp_output"
    return 1
  fi

  rm -f "$temp_output"
  echo "✅ SUCCESS: Correctly handled invalid parameter"
  return 0
}

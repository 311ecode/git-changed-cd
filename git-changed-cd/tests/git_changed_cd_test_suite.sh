git_changed_cd_test_suite() {
  export LC_NUMERIC=C # 🔢 Ensure consistent numeric formatting

  # Save environment state 🔒
  local saved_debug="${DEBUG:-}"
  local saved_pwd="${PWD:-}"

  # Test function registry 📋
  local test_functions=(
    "git_changed_cd_test_not_in_git_repo"
    "git_changed_cd_test_clean_repo"
    "git_changed_cd_test_unstaged_file_navigation"
    "git_changed_cd_test_staged_file_parent_dirs"
    "git_changed_cd_test_untracked_file_navigation"
    "git_changed_cd_test_cancellation"
    "git_changed_cd_test_invalid_non_numeric_input"
    "git_changed_cd_test_out_of_range_selection"
    "git_changed_cd_test_debug_mode"
    "git_changed_cd_test_missing_target_directory"
  )

  local ignored_tests=() # 🚫 No tests to skip

  # Run tests with bashTestRunner 🚀
  bashTestRunner test_functions ignored_tests

  local result=$?

  # Restore environment ✨
  if [[ -n $saved_debug ]]; then
    export DEBUG="$saved_debug"
  else
    unset DEBUG
  fi
  cd "$saved_pwd" || return 1

  return $result # 🎉 Done!
}

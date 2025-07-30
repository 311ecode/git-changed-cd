git_changed_cd_test_suite() {
  export LC_NUMERIC=C # 🔢 Ensure consistent numeric formatting

  # Save environment state 🔒
  local saved_debug="${DEBUG:-}"
  local saved_pwd="${PWD:-}"
  local saved_registry="${GIT_CHANGED_CD_REGISTERED_REPOS:-}"

  # Test function registry 📋
local test_functions=(
    # Original tests
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
    # Registry management tests
    "git_changed_cd_test_add_repo_success"
    "git_changed_cd_test_add_repo_duplicate"
    "git_changed_cd_test_add_repo_nonexistent"
    "git_changed_cd_test_add_repo_not_git"
    "git_changed_cd_test_add_repo_no_parameter"
    "git_changed_cd_test_remove_repo_success"
    "git_changed_cd_test_remove_repo_not_registered"
    "git_changed_cd_test_remove_repo_nonexistent"
    "git_changed_cd_test_remove_repo_no_parameter"
    "git_changed_cd_test_invalid_parameter"
    "git_changed_cd_test_registry_functions"
    # Registry list tests
    "git_changed_cd_test_list_repos_empty"
    "git_changed_cd_test_list_repos_single"
    "git_changed_cd_test_list_repos_multiple"
    "git_changed_cd_test_list_repos_help"
    "git_changed_cd_test_list_repos_invalid_parameter"
    "git_changed_cd_test_list_repos_alias"
    # Multi-repo functionality tests
    "git_changed_cd_test_just_registered_directories"
    "git_changed_cd_test_all_mode"
    "git_changed_cd_test_no_registered_repos"
    "git_changed_cd_test_aliases"
    "git_changed_cd_test_help_message"
    "git_changed_cd_test_sequential_numbering"
    # New multi-repo display and distance ordering tests
    "git_changed_cd_test_current_repo_display"
    "git_changed_cd_test_current_vs_registered_display"
    "git_changed_cd_test_path_distance_calculation"
    "git_changed_cd_test_distance_ordering"
    "git_changed_cd_test_all_mode_distance_ordering"
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
  
  if [[ -n $saved_registry ]]; then
    export GIT_CHANGED_CD_REGISTERED_REPOS="$saved_registry"
  else
    unset GIT_CHANGED_CD_REGISTERED_REPOS
  fi
  
  cd "$saved_pwd" || return 1

  return $result # 🎉 Done!
}
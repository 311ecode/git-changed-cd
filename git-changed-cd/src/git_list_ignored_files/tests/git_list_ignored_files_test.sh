#!/usr/bin/env bash
# @file tests/git_list_ignored_files_test.sh
# @brief Test suite for git_list_ignored_files script
# @description Comprehensive tests for listing ignored files in a Git repository using bashTestRunner

testGitListIgnoredFiles() {
  export LC_NUMERIC=C  # 🔢 Ensure consistent numeric formatting

  # Test function registry 📋
  local test_functions=(
    "testGitListIgnoredFilesValidGitRepoWithIgnoredFiles"
    "testGitListIgnoredFilesNonExistentPath"
    "testGitListIgnoredFilesNonGitRepo"
    "testGitListIgnoredFilesCachedResults"
    "testGitListIgnoredFilesEmptyIgnoredList"
  )

  local ignored_tests=()  # 🚫 Add tests to skip if needed

  # Run tests with consistent numeric formatting
  bashTestRunner test_functions ignored_tests
  return $?
}


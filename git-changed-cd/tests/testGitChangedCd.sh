#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.

# @file tests/git-changed-cd.sh
# @brief Test suite for git-changed-cd (gcd) Bash function
# @description Comprehensive tests for git-changed-cd using bashTestRunner framework

testGitChangedCd() {
  export LC_NUMERIC=C  # 🔢 Ensure consistent numeric formatting

  # Save environment state 🔒
  local saved_debug="${DEBUG:-}"
  local saved_pwd="${PWD:-}"

  # Test function registry 📋
  local test_functions=(
    "testNotInGitRepo"
    "testCleanRepo"
    "testUnstagedFileNavigation"
    "testStagedFileParentDirs"
    "testUntrackedFileNavigation"
    "testCancellation"
    "testInvalidNonNumericInput"
    "testOutOfRangeSelection"
    "testDebugMode"
    "testMissingTargetDirectory"
  )

  local ignored_tests=()  # 🚫 No tests to skip

  # Run tests with bashTestRunner 🚀
  bashTestRunner test_functions ignored_tests

  local result=$?

  # Restore environment ✨
  if [[ -n "$saved_debug" ]]; then
    export DEBUG="$saved_debug"
  else
    unset DEBUG
  fi
  cd "$saved_pwd" || return 1

  return $result  # 🎉 Done!
}


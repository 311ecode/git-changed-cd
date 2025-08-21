git_changed_cd_test_registry_functions() {
  echo "🧪 Testing registry functions directly"

  # Save current state
  local saved_registry="${GIT_CHANGED_CD_REGISTERED_REPOS:-}"

  # Test initialization
  unset GIT_CHANGED_CD_REGISTERED_REPOS
  git_changed_cd_registry_init
  if [[ "${GIT_CHANGED_CD_REGISTERED_REPOS:-}" != "" ]]; then
    echo "❌ ERROR: Registry should be empty after init"
    return 1
  fi

  # Test count of empty registry
  local count=$(git_changed_cd_registry_count)
  if [[ "$count" != "0" ]]; then
    echo "❌ ERROR: Empty registry should have count 0, got $count"
    return 1
  fi

  # Test adding
  git_changed_cd_registry_add "/path/one"
  if [[ "$GIT_CHANGED_CD_REGISTERED_REPOS" != "/path/one" ]]; then
    echo "❌ ERROR: Registry should contain '/path/one', got '$GIT_CHANGED_CD_REGISTERED_REPOS'"
    return 1
  fi

  # Test contains
  if ! git_changed_cd_registry_contains "/path/one"; then
    echo "❌ ERROR: Registry should contain '/path/one'"
    return 1
  fi

  if git_changed_cd_registry_contains "/path/two"; then
    echo "❌ ERROR: Registry should not contain '/path/two'"
    return 1
  fi

  # Test adding second
  git_changed_cd_registry_add "/path/two"
  if [[ "$GIT_CHANGED_CD_REGISTERED_REPOS" != "/path/one:/path/two" ]]; then
    echo "❌ ERROR: Registry should contain both paths, got '$GIT_CHANGED_CD_REGISTERED_REPOS'"
    return 1
  fi

  # Test count
  count=$(git_changed_cd_registry_count)
  if [[ "$count" != "2" ]]; then
    echo "❌ ERROR: Registry should have count 2, got $count"
    return 1
  fi

  # Test removal
  git_changed_cd_registry_remove "/path/one"
  if [[ "$GIT_CHANGED_CD_REGISTERED_REPOS" != "/path/two" ]]; then
    echo "❌ ERROR: Registry should contain only '/path/two', got '$GIT_CHANGED_CD_REGISTERED_REPOS'"
    return 1
  fi

  # Test removal of last item
  git_changed_cd_registry_remove "/path/two"
  if [[ -n "${GIT_CHANGED_CD_REGISTERED_REPOS:-}" ]]; then
    echo "❌ ERROR: Registry should be unset after removing last item, got '$GIT_CHANGED_CD_REGISTERED_REPOS'"
    return 1
  fi

  # Restore state
  if [[ -n "$saved_registry" ]]; then
    export GIT_CHANGED_CD_REGISTERED_REPOS="$saved_registry"
  else
    unset GIT_CHANGED_CD_REGISTERED_REPOS
  fi

  echo "✅ SUCCESS: Registry functions work correctly"
  return 0
}

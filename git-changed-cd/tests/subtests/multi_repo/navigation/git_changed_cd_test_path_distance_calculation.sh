git_changed_cd_test_path_distance_calculation() {
  echo "🧪 Testing path distance calculation function"
  local temp_dir=$(mktemp -d)

  # Create directory structure
  mkdir -p "$temp_dir/a/b/c"
  mkdir -p "$temp_dir/x/y"
  mkdir -p "$temp_dir/same_level"

  # Test from temp_dir/a/b
  cd "$temp_dir/a/b" || return 1

  # Test distance to parent (should be 1)
  local dist1=$(git_changed_cd_calculate_path_distance "$temp_dir/a")
  if [[ $dist1 != "1" ]]; then
    echo "❌ ERROR: Distance to parent should be 1, got $dist1"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Test distance to child (should be 1)
  local dist2=$(git_changed_cd_calculate_path_distance "$temp_dir/a/b/c")
  if [[ $dist2 != "1" ]]; then
    echo "❌ ERROR: Distance to child should be 1, got $dist2"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Test distance to sibling branch (should be 3: up 2, down 1)
  local dist3=$(git_changed_cd_calculate_path_distance "$temp_dir/same_level")
  if [[ $dist3 != "3" ]]; then
    echo "❌ ERROR: Distance to sibling should be 3, got $dist3"
    cd "$saved_pwd" || return 1
    return 1
  fi

  # Test distance to cousin (should be 4: up 2, down 2)
  local dist4=$(git_changed_cd_calculate_path_distance "$temp_dir/x/y")
  if [[ $dist4 != "4" ]]; then
    echo "❌ ERROR: Distance to cousin should be 4, got $dist4"
    cd "$saved_pwd" || return 1
    return 1
  fi

  cd "$saved_pwd" || return 1
  echo "✅ SUCCESS: Path distance calculation works correctly"
  return 0
}

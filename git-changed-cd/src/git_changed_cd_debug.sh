#!/usr/bin/env bash
git_changed_cd_debug() {
  [[ -n $DEBUG ]] && echo "DEBUG[git-changed-cd]: $1" >&2
}

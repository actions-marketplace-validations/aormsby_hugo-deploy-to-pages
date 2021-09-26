#!/bin/sh

# source test scripts, then run individual functions

# shellcheck disable=SC1091
. "${ACTION_PARENT_DIR}"/test/verify_git_config.sh
test_config_git

# shellcheck disable=SC1091
. "${ACTION_PARENT_DIR}"/test/verify_branches.sh
test_source_branch_exists
test_release_branch_exists
#!/usr/bin/env bats
#
# bats-core test script

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-file/load'
  load 'test_helper/bats-assert/load'
  
  DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" >/dev/null 2>&1 && pwd)"
  PATH="${DIR}/../src:${PATH}"
}

@test "script file exists" {
  assert_file_exists src/rsync_backup
}

@test "script file is executable" {
  assert_file_executable src/rsync_backup
}

@test "fail when run without command options" {
  run rsync_backup
  assert_failure
}
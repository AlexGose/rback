#!/usr/bin/env bats
#
# bats-core test script

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-file/load'
  load 'test_helper/bats-assert/load'
  
  PATH="${BATS_TEST_DIRNAME}/../src:${PATH}"
}

@test "script file exists" {
  assert_file_exists src/rsync_backup
}

@test "script file is executable" {
  assert_file_executable src/rsync_backup
}

@test "script fails without command options" {
  run rsync_backup
  assert_failure
}

check_usage_output() {
  assert_success
  assert_output --partial "Usage:"
  assert_output --partial "-h"
}

@test "test usage function" {
  source rsync_backup
  run usage
  check_usage_output
}

@test "script prints usage with \"-h\" option" {
  run rsync_backup -h
  check_usage_output
}

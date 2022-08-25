#!/usr/bin/env bats
#
# bats-core test script

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-file/load'
  load 'test_helper/bats-assert/load'
  
  PATH="${BATS_TEST_DIRNAME}/../src:${PATH}"
  
  TEMP_TEST_DIR="$(mktemp -d /tmp/rsync_backup_test_XXXXX)"

  work_dir="${PWD}"
  cd "${TEMP_TEST_DIR}"
  mkdir hour.{2,4,6}
  touch hour.2/a hour.4/b hour.6/c
  cd "${work_dir}"
}

teardown() {
  rm -rf "${TEMP_TEST_DIR}"
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

@test "rotate_snapshots function rotates 3 snapshot folders" {
  source rsync_backup

  run rotate_snapshots "${TEMP_TEST_DIR}" hour 2 6
  assert_success
  assert_file_exists "${TEMP_TEST_DIR}/hour.2/c"
  assert_file_exists "${TEMP_TEST_DIR}/hour.4/a"
  assert_file_exists "${TEMP_TEST_DIR}/hour.6/b"
}

@test "rotate_snapshots function fails if limit + interval folder exists" {
  source rsync_backup

  run rotate_snapshots "${TEMP_TEST_DIR}" hour 2 4
  assert_failure
  assert_output --partial "${TEMP_TEST_DIR}/hour.6 already exists"
}

@test "rotate_snapshots creates empty first folder if no last folder" {
  source rsync_backup

  run rotate_snapshots "${TEMP_TEST_DIR}" hour 2 10
  assert_success
  assert_dir_exists "${TEMP_TEST_DIR}/hour.2"
  [ "$(ls ${TEMP_TEST_DIR}/hour.2)" == "" ]
}

@test "rotate_snapshots creates empty folder if no snapshot folders exist" {
  source rsync_backup
  run rotate_snapshots "${TEMP_TEST_DIR}" hour 8 16
  assert_dir_exists "${TEMP_TEST_DIR}/hour.8"
  [ "$(ls ${TEMP_TEST_DIR}/hour.8)" == "" ]
}

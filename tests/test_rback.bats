#!/usr/bin/env bats
#
# bats-core test script

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-file/load'
  load 'test_helper/bats-assert/load'
  
  PATH="${BATS_TEST_DIRNAME}/../src:${PATH}"
  
  TEMP_TEST_DIR="$(mktemp -d /tmp/rback_test_XXXXX)"

  work_dir="${PWD}"
  cd "${TEMP_TEST_DIR}"
  mkdir hour.{2,4,6}.2
  touch hour.2.2/a hour.4.2/b hour.6.2/c
  cd "${work_dir}"

  source rback
}

teardown() {
  rm -rf "${TEMP_TEST_DIR}"
}

@test "script file exists" {
  assert_file_exists src/rback
}

@test "script file is executable" {
  assert_file_executable src/rback
}

@test "script fails without command options" {
  run rback
  assert_failure
}

check_usage_output() {
  assert_success
  assert_output --partial "Usage:"
  assert_output --partial "-h"
}

@test "test usage function" {
  run usage
  check_usage_output
}

@test "script prints usage with \"-h\" option" {
  run rback -h
  check_usage_output
}

@test "script prints usage with \"--help\" option" {
  run rback --help
  check_usage_output
}

@test "rotate function rotates 3 snapshot folders" {
  run rotate "${TEMP_TEST_DIR}" hour 2 2 6
  assert_success
  assert_file_exists "${TEMP_TEST_DIR}/hour.2.2/c"
  assert_file_exists "${TEMP_TEST_DIR}/hour.4.2/a"
  assert_file_exists "${TEMP_TEST_DIR}/hour.6.2/b"
}

@test "rotate function fails if limit + interval folder exists" {
  run rotate "${TEMP_TEST_DIR}" hour 2 2 4
  assert_failure
  assert_output --partial "${TEMP_TEST_DIR}/hour.6.2 already exists"
}

@test "rotate creates empty first folder if no last folder" {
  run rotate "${TEMP_TEST_DIR}" hour 2 2 10
  assert_success
  assert_dir_exists "${TEMP_TEST_DIR}/hour.2.2"
  [ "$(ls ${TEMP_TEST_DIR}/hour.2.2)" == "" ]
}

@test "rotate function creates empty folder if no snapshot folders exist" {
  run rotate "${TEMP_TEST_DIR}" hour 8 8 16
  assert_dir_exists "${TEMP_TEST_DIR}/hour.8.8"
  [ "$(ls ${TEMP_TEST_DIR}/hour.8.8)" == "" ]
}

@test "rotate function with start different from interval" {
  mkdir "${TEMP_TEST_DIR}/hour.0.2"
  touch "${TEMP_TEST_DIR}/hour.0.2/d"
  run rotate "${TEMP_TEST_DIR}" hour 0 2 6
  assert_success
  assert_file_exists "${TEMP_TEST_DIR}/hour.0.2/c"
  assert_file_exists "${TEMP_TEST_DIR}/hour.2.2/d"
  assert_file_exists "${TEMP_TEST_DIR}/hour.4.2/a"
  assert_file_exists "${TEMP_TEST_DIR}/hour.6.2/b"
}

@test "README file usage information matches help from script" {
  run cat README.md
  assert_output --partial "$(src/rback -h)"
}

@test "script fails with unknown option \"-z\"" {
  run rback -z
  assert_failure
  assert_output --partial "Unknown option \"-z\""
}

@test "script fails with incorrect number of command line arguments" {
  run rback minute 10 120 10 "${TEMP_TEST_DIR}/files" "${TEMP_TEST_DIR}" "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "6 or 8 expected"
}

@test "script fails with \"--\" and one too few command line arguments" {
  run rback -- minute 10 120 10 "${TEMP_TEST_DIR}/files"
  assert_failure
  assert_output --partial "6 or 8 expected"
}

@test "script backs up file and removes extra file" {
  mkdir "${TEMP_TEST_DIR}/files"
  echo "hello world" >"${TEMP_TEST_DIR}/files/test_file.txt"
  run rback hour 2 2 6 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"
  assert_success
  assert_file_exists "${TEMP_TEST_DIR}/hour.2.2/test_file.txt"
  assert_file_not_exists "${TEMP_TEST_DIR}/hour.2.2/c"
}

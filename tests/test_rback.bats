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

  assert_dir_exists "${TEMP_TEST_DIR}"
  assert_dir_not_exists "${TEMP_TEST_DIR}/hour.4.4"
  assert_dir_not_exists "${TEMP_TEST_DIR}/hour.8.4"
  assert_dir_not_exists "${TEMP_TEST_DIR}/hour.12.4"

  source rback
}

teardown() {
  rm -rf "${TEMP_TEST_DIR}"
}

check_usage_output() {
  assert_success
  assert_output --partial "Usage:"
  assert_output --partial "-h"
}

get_inode() {
  ls -i "$1" | awk '{print $1}'
}

assert_inodes_equal() {
  [ "$(get_inode "$1")" == "$(get_inode "$2")" ]
}

assert_inodes_not_equal() {
  [ "$(get_inode "$1")" != "$(get_inode "$2")" ]
}

assert_current_timestamp() {
  (( $(date +%s) - $(date -d "${output:0:19}" +%s) < 5 )) # within 5 second
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

@test "script with \"-r\" option fails with too many command line arguments" {
  run rback -r minute 10 120 10 hour 2 2 "${TEMP_TEST_DIR}/files" \
      "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "expected 8"
}

@test "script fails with fewer than 6 command line arguments" {
  run rback -- minute 30 30 480 "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "at least 6 required"
  run rback --rotate minute 30 30 480 "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "at least 6 required"
}

@test "script fails with \"--\" and one too few command line arguments" {
  run rback -r -- minute 10 120 10 hour 2 2
  assert_failure
  assert_output --partial "expected 8"
}

@test "script backs up file and removes extra file" {
  mkdir "${TEMP_TEST_DIR}/files"
  echo "hello world" >"${TEMP_TEST_DIR}/files/test_file.txt"
  run rback hour 2 2 6 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"
  assert_success
  assert_file_exists "${TEMP_TEST_DIR}/hour.2.2/test_file.txt"
  assert_file_not_exists "${TEMP_TEST_DIR}/hour.2.2/c"
  assert_inodes_not_equal "${TEMP_TEST_DIR}/hour.2.2/test_file.txt" \
      "${TEMP_TEST_DIR}/files/test_file.txt" 
}

@test "script backs up files from two directories" {
  mkdir "${TEMP_TEST_DIR}/dir with spaces" "${TEMP_TEST_DIR}/files"
  touch "${TEMP_TEST_DIR}/dir with spaces/a" "${TEMP_TEST_DIR}/files/b"
  run rback -- hour 2 2 6 "${TEMP_TEST_DIR}/dir with spaces/" \
      "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"
  assert_success
  assert_file_exists "${TEMP_TEST_DIR}/hour.2.2/a"
  assert_file_exists "${TEMP_TEST_DIR}/hour.2.2/b"
}

@test "script creates hard link from previous snapshot folder" {
  mkdir "${TEMP_TEST_DIR}/files"
  echo "hello world" >"${TEMP_TEST_DIR}/files/test_file.txt"
  cp "${TEMP_TEST_DIR}/files/test_file.txt" \
     "${TEMP_TEST_DIR}/hour.2.2/test_file.txt"
  run rback hour 2 2 6 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"
  assert_success
  assert_inodes_equal "${TEMP_TEST_DIR}/hour.2.2/test_file.txt" \
      "${TEMP_TEST_DIR}/hour.4.2/test_file.txt" 
  assert_inodes_not_equal "${TEMP_TEST_DIR}/hour.2.2/test_file.txt" \
      "${TEMP_TEST_DIR}/files/test_file.txt" 
}

@test "script updates snapshot with another snapshot" {
  touch "${TEMP_TEST_DIR}/hour.6.2/a.txt"
  touch "${TEMP_TEST_DIR}/hour.6.2/b.txt"
  mkdir "${TEMP_TEST_DIR}/minute.120.30"
  ln "${TEMP_TEST_DIR}/hour.6.2/a.txt" "${TEMP_TEST_DIR}/minute.120.30/a.txt"
  touch "${TEMP_TEST_DIR}/minute.120.30/c.txt"

  run rback --rotate -- hour 2 2 6 minute 120 30 "${TEMP_TEST_DIR}"
  assert_success
  assert_file_not_exists "${TEMP_TEST_DIR}/hour.2.2/b.txt"
  assert_file_exists "${TEMP_TEST_DIR}/hour.2.2/c.txt"
  assert_inodes_equal "${TEMP_TEST_DIR}/minute.120.30/a.txt" \
      "${TEMP_TEST_DIR}/hour.2.2/a.txt" 
  assert_inodes_equal "${TEMP_TEST_DIR}/minute.120.30/c.txt" \
      "${TEMP_TEST_DIR}/hour.2.2/c.txt" 
}

@test "script fails when given invalid second argument" {
  mkdir "${TEMP_TEST_DIR}/files"
  run rback hour 2.2 2 6 "${TEMP_TEST_DIR}/files" "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "expected a positive integer"
  assert_output --partial "second argument"
}


@test "script fails when given invalid third argument" {
  mkdir "${TEMP_TEST_DIR}/files"
  run rback hour 2 -07 6 "${TEMP_TEST_DIR}/files" "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "expected a positive integer"
  assert_output --partial "third argument"
}

@test "script fails when given invalid fourth argument" {
  mkdir "${TEMP_TEST_DIR}/files"
  run rback hour 2 2 0 "${TEMP_TEST_DIR}/files" "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "expected a positive integer"
  assert_output --partial "fourth argument"
}

@test "script fails with \"-r\" option and invalid sixth argument" {
  mkdir "${TEMP_TEST_DIR}/files"
  run rback -r hour 2 2 6 minute 120.5 30 "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "expected a positive integer"
  assert_output --partial "sixth argument"
}

@test "script fails with \"-r\" option and invalid seventh argument" {
  mkdir "${TEMP_TEST_DIR}/files"
  run rback -r hour 2 2 6 minute 120 thirty "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "expected a positive integer"
  assert_output --partial "seventh argument"
}

@test "the user backs up a file but excludes another file" {
  mkdir "${TEMP_TEST_DIR}/files"
  touch "${TEMP_TEST_DIR}/files/my_file.txt" # file to backup
  touch "${TEMP_TEST_DIR}/files/exclude_me.txt" # file to exclude
  
  echo "- exclude_me.txt" > "${TEMP_TEST_DIR}/excludes"
  run rback -x "${TEMP_TEST_DIR}/excludes" -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}/"
  
  assert_success
  diff "${TEMP_TEST_DIR}/files/my_file.txt" "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
  assert_file_not_exists "${TEMP_TEST_DIR}/hour.4.4/exclude_me.txt"
}

@test "the user backs up a file but excludes a non-empty directory" {
  mkdir "${TEMP_TEST_DIR}/files"
  mkdir "${TEMP_TEST_DIR}/files/do_not_copy"
  echo "hello world" > "${TEMP_TEST_DIR}/files/do_not_copy/hello"
  touch "${TEMP_TEST_DIR}/files/my_file.txt"

  echo "- do_not_copy" > "${TEMP_TEST_DIR}/excludes"
  run rback -x "${TEMP_TEST_DIR}/excludes" -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}/"

  assert_success
  diff "${TEMP_TEST_DIR}/files/my_file.txt" "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
  assert_dir_not_exists "${TEMP_TEST_DIR}/hour.4.4/do_not_copy"
}

@test "the user backs up a file in a directory but excludes a non-empty subdirectory" {
  mkdir -p "${TEMP_TEST_DIR}/files/subdir/do_not_copy"
  echo "hello world" > "${TEMP_TEST_DIR}/files/subdir/do_not_copy/hello.txt"
  touch "${TEMP_TEST_DIR}/files/subdir/my_file.txt"

  echo "- subdir/do_not_copy" > "${TEMP_TEST_DIR}/excludes"
  run rback -x "${TEMP_TEST_DIR}/excludes" -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}/"

  assert_success
  diff "${TEMP_TEST_DIR}/files/subdir/my_file.txt" "${TEMP_TEST_DIR}/hour.4.4/subdir/my_file.txt"
  assert_dir_not_exists "${TEMP_TEST_DIR}/hour.4.4/subdir/do_not_copy"
}

@test "the user looks up the command line option for an exclusion file" {
  run rback -h
  assert_output --regexp "rback \[ .*--exclude-file <filename> \]"
  assert_output --regexp "rback -r \[ .*--exclude-file <filename> \]"
  assert_output --partial "-x, --exclude-file"
}

@test "the user backs up a file without deleting an excluded file in backup" {
  mkdir "${TEMP_TEST_DIR}/files"
  touch "${TEMP_TEST_DIR}/files/my_file.txt"
  echo "- exclude_me.txt" > "${TEMP_TEST_DIR}/excludes"
  mkdir "${TEMP_TEST_DIR}/hour.12.4"
  touch "${TEMP_TEST_DIR}/hour.12.4/exclude_me.txt"
  assert_file_not_exists "${TEMP_TEST_DIR}/files/exclude_me.txt"

  run rback -x "${TEMP_TEST_DIR}/excludes" -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"

  assert_success
  diff "${TEMP_TEST_DIR}/files/my_file.txt" "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
  assert_file_exists "${TEMP_TEST_DIR}/hour.4.4/exclude_me.txt"
}

@test "The user backs up a file and deletes an excluded file in backup" {
  mkdir "${TEMP_TEST_DIR}/files"
  touch "${TEMP_TEST_DIR}/files/my_file.txt"
  echo "- exclude_me.txt" > "${TEMP_TEST_DIR}/excludes"
  mkdir "${TEMP_TEST_DIR}/hour.12.4"
  touch "${TEMP_TEST_DIR}/hour.12.4/exclude_me.txt"
  assert_file_not_exists "${TEMP_TEST_DIR}/files/exclude_me.txt"

  run rback --delete-excluded -x "${TEMP_TEST_DIR}/excludes" -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"

  assert_success
  diff "${TEMP_TEST_DIR}/files/my_file.txt" "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
  assert_file_not_exists "${TEMP_TEST_DIR}/hour.4.4/exclude_me.txt"
}

@test "The user backs up a file without deleting a non-empty backup directory" {
  mkdir "${TEMP_TEST_DIR}/files"
  touch "${TEMP_TEST_DIR}/files/my_file.txt"
  echo "- do_not_delete" > "${TEMP_TEST_DIR}/excludes"
  mkdir -p "${TEMP_TEST_DIR}/hour.12.4/do_not_delete" 
  echo "hello world" > "${TEMP_TEST_DIR}/hour.12.4/do_not_delete/hello.txt"
  assert_file_not_exists "${TEMP_TEST_DIR}/files/do_not_delete"
  
  run rback -x "${TEMP_TEST_DIR}/excludes" -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"

  assert_success
  diff "${TEMP_TEST_DIR}/files/my_file.txt" "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
  assert_dir_exists "${TEMP_TEST_DIR}/hour.4.4/do_not_delete"
  assert_file_exists "${TEMP_TEST_DIR}/hour.4.4/do_not_delete/hello.txt"
}

@test "The user backs up a file and deletes a non-empty backup directory" {
  mkdir "${TEMP_TEST_DIR}/files"
  touch "${TEMP_TEST_DIR}/files/my_file.txt"
  echo "- delete_me" > "${TEMP_TEST_DIR}/excludes"
  mkdir -p "${TEMP_TEST_DIR}/hour.12.4/delete_me" 
  echo "hello world" > "${TEMP_TEST_DIR}/hour.12.4/delete_me/hello.txt"
  assert_file_not_exists "${TEMP_TEST_DIR}/files/delete_me"
 
  run rback --delete-excluded -x "${TEMP_TEST_DIR}/excludes" -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"

  assert_success
  diff "${TEMP_TEST_DIR}/files/my_file.txt" "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
  assert_dir_not_exists "${TEMP_TEST_DIR}/hour.4.4/delete_me"
}

@test "The user forgets the \"-x\" option when using \"--delete-excluded\"" {
  mkdir "${TEMP_TEST_DIR}/files"
  touch "${TEMP_TEST_DIR}/files/my_file.txt"
run rback --delete-excluded -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"
  assert_failure
  assert_output --partial "\"-x\" is required with \"-d\""
}

@test "the user looks up usage info for deleting excluded files and folders" {
  run rback -h
  assert_output --regexp "rback .*[ [ --delete-excluded ] "
  assert_output --regexp "rback -r .*[ [ --delete-excluded ] "
  assert_output --partial "-d, --delete-excluded"
}

@test "the user backs up a directory with a log message to standard out" {
  mkdir "${TEMP_TEST_DIR}/files"
  
  run rback -v -- hour 4 4 12 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"

  assert_success
  assert_output --partial "backup completed"
  assert_current_timestamp
}

@test "the user rotates snapshots with a log message to standard out" {
  mkdir "${TEMP_TEST_DIR}/minute.240.30"

  run rback -r -v -- hour 4 4 8 minute 240 30 "${TEMP_TEST_DIR}"

  assert_success
  assert_output --partial "snapshot rotation completed"
  assert_current_timestamp
}

@test "the user tries to backup a non-existent folder with logging enabled" {
  assert_dir_not_exists "${TEMP_TEST_DIR}/files"

  run rback -v -- hour 4 4 12 "${TEMP_TEST_DIR}/files" "${TEMP_TEST_DIR}"

  assert_failure
  assert_output --partial "Rsync error"
  assert_current_timestamp
}

@test "the user passes an invalid argument with logging enabled" {
  mkdir "${TEMP_TEST_DIR}/files"

  run rback -v -- hour 2.2 2 6 "${TEMP_TEST_DIR}/files" "${TEMP_TEST_DIR}"

  assert_failure
  assert_output --partial "second argument"
  assert_current_timestamp
}

@test "the user passes an unknown option with logging enabled" {
  mkdir "${TEMP_TEST_DIR}/files"

  run rback -z -v -- hour 2 2 6 "${TEMP_TEST_DIR}/files" "${TEMP_TEST_DIR}"

  assert_failure
  assert_output --partial "Unknown option \"-z\""
  assert_current_timestamp
}

@test "the user looks up the command line option for logging" {
  run rback -h

  assert_output --partial "rback [ -v ] "
  assert_output --partial "rback -r [ -v ] "
  assert_output --partial "-x, --exclude-file"
}

@test "the user enters a limit argument less than the start argument" {
  mkdir "${TEMP_TEST_DIR}/files"

  run rback -- hour 2 2 1 "${TEMP_TEST_DIR}/files/" "${TEMP_TEST_DIR}"

  assert_failure
  assert_output --partial "START 2 exceeds LIMIT 1"
}

Feature: Allow for the use of an exclusion file

Background:
    Given the user has an open terminal with a command line prompt
    And "${TEMP_TEST_DIR}" is a valid path to a directory
    And the rback script is on the path
    And Rsync is installed
    And none of the relevant backup snapshot directories exist in "${TEMP_TEST_DIR}"


Scenario: The user backs up a file but excludes another file
    Given the file to exclude is "${TEMP_TEST_DIR}/files/exclude_me.txt"
    And the file to backup is "${TEMP_TEST_DIR}/files/my_file.txt"
    When the user creates a file "${TEMP_TEST_DIR}/excludes" with one line "- exclude_me.txt"
    And executes "rback -x ${TEMP_TEST_DIR}/excludes -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}/"
    Then the command succeeds
    And a copy of "${TEMP_TEST_DIR}/files/my_file.txt" is made at "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
    But "${TEMP_TEST_DIR}/files/exclude_me.txt" was not copied into the "${TEMP_TEST_DIR}/hour.4.4/" directory
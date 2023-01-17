Feature: Delete excluded files or folders in backup folders with "--delete-excluded"

Background:
   Given the user has an open terminal with a command line prompt
   And "${TEMP_TEST_DIR}" is a valid path to a directory
   And the rback script is on the path
   And Rsync is installed
   And the file to save is "${TEMP_TEST_DIR}/files/my_file.txt"


Scenario: The user backs up a file without deleting an excluded file in backup
    Given the file "${TEMP_TEST_DIR}/excludes" has one line "- exclude_me.txt"
    And the file "${TEMP_TEST_DIR}/hour.12.4/exclude_me.txt" does exist
    But the file "${TEMP_TEST_DIR}/files/exclude_me.txt" does not exist
    When the user executes "rback -x ${TEMP_TEST_DIR}/excludes -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}/"
    Then the command succeeds
    And a copy of "${TEMP_TEST_DIR}/files/my_file.txt" is made at "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
    And the file "${TEMP_TEST_DIR}/hour.4.4/exclude_me.txt" exists

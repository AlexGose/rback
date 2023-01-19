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

Scenario: The user backs up a file and deletes an excluded file in backup
    Given the file "${TEMP_TEST_DIR}/excludes" has one line "- exclude_me.txt"
    And the file "${TEMP_TEST_DIR}/hour.12.4/exclude_me.txt" does exist
    But the file "${TEMP_TEST_DIR}/files/exclude_me.txt" does not exist
    When the user executes "rback --delete-excluded -x ${TEMP_TEST_DIR}/excludes -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}/"
    Then the command succeeds
    And a copy of "${TEMP_TEST_DIR}/files/my_file.txt" is made at "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
    But the file "${TEMP_TEST_DIR}/hour.4.4/exclude_me.txt" does not exists

Scenario: The user backs up a file without deleting a non-empty backup directory
    Given the file "${TEMP_TEST_DIR}/excludes" has one line "- do_not_delete"
    And the non-empty directory "${TEMP_TEST_DIR}/hour.12.4/do_not_delete" exists
    But the non-empty directory "${TEMP_TEST_DIR}/files/do_not_delete" does not exist
    When the user executes "rback -x ${TEMP_TEST_DIR}/excludes -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}/"
    Then the command succeeds
    And a copy of "${TEMP_TEST_DIR}/files/my_file.txt" is made at "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
    And the non-empty directory "${TEMP_TEST_DIR}/hour.4.4/do_not_delete" exists

Scenario: The user backs up a file and deletes a non-empty backup directory
    Given the file "${TEMP_TEST_DIR}/excludes" has one line "- delete_me"
    And the non-empty directory "${TEMP_TEST_DIR}/hour.12.4/delete_me" exists
    But the directory "${TEMP_TEST_DIR}/files/delete_me" does not exist
    When the user executes "rback --delete-excluded -x ${TEMP_TEST_DIR}/excludes -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}/"
    Then the command succeeds
    And a copy of "${TEMP_TEST_DIR}/files/my_file.txt" is made at "${TEMP_TEST_DIR}/hour.4.4/my_file.txt"
    But the directory "${TEMP_TEST_DIR}/hour.4.4/delete_me" does not exist

Scenario: The user forgets the "-x" option when using "--delete-excluded"
    When the user executes "rback --delete-excluded -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}/"
    Then the command fails
    And the error message '"-x" is required with "-d"' appears

Scenario: The user looks up usage info for deleting excluded files and folders
    When the user types "rback -h"
    Then "rback [ [ --delete-excluded ] ..." is shown in the usage information for "rback"
    And "rback -r [ [ --delete-excluded ] ..." is shown in the usage information for "rback -r"
    And the options "-d, --delete-excluded" appear as well

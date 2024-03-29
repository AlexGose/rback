Feature: Add the ability to print log messages with "-v"

Background:
    Given the user has an open terminal with a command line prompt
    And "${TEMP_TEST_DIR}" is a valid path to a directory
    And the rback script is on the path
    And Rsync is installed


Scenario: The user backs up a directory with a log message to standard out
    Given the directory to backup is "${TEMP_TEST_DIR}/files/"
    When the user executes "rback -v -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}"
    Then the command succeeds
    And a message is printed to standard out
    And the message contains the phrase "backup completed"
    And the message contains the current timestamp within a 5 second difference

Scenario: The user rotates snapshots with a log message to standard out
    Given the snapshot directory "${TEMP_TEST_DIR}/minute.240.30" exists
    When the user executes "rback -r -v -- hour 4 4 8 minute 240 30 ${TEMP_TEST_DIR}"
    Then the command succeeds
    And a message is printed to standard out
    And the message contains the phrase "snapshot rotation completed"
    And the message contains the current timestamp within a 5 second difference

Scenario: The user tries to backup a non-existent folder with logging enabled
    Given the directory to back up "${TEMP_TEST_DIR}/files/" does not exist
    When the user executes "rback -v -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase "Rsync error"
    And the message contains the current time stamp within a 5 second difference

Scenario: The user passes an invalid argument with logging enabled
    Given the directory "${TEMP_TEST_DIR}/files" to back up exists
    When the user executes "rback -v -- hour 2.2 2 6 ${TEMP_TEST_DIR}/files ${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase "second argument"
    And the message contains the current time stamp within a 5 second difference

Scenario: The user passes an unknown option with logging enabled
    Given the directory "${TEMP_TEST_DIR}/files" to back up exists
    When the user executes "rback -z -v -- hour 2 2 6 ${TEMP_TEST_DIR}/files ${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase 'Unknown option "-z"'
    And the message contains the current time stamp within a 5 second difference

Scenario: The user looks up the command line option for logging
    When the user enters "rback -h"
    Then "[ -v ]" is shown in the usage information for "rback"
    And "[ -v ]" is shown in the usage information for "rback -r"
    And the options "-v, --verbose" appear as well

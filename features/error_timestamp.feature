Feature: print timestamps for all error messages with "-v"

Background:
    Given the user has an open terminal with a command line prompt
    And "${TEMP_TEST_DIR}" is a valid path to a directory
    And the rback script is on the path
    And Rsync is installed


Scenario: The user passes fewer than 6 arguments with "-v"
    When the user executes "rback -v -- minute 30 30 480 "${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase "at least 6 required"
    And the message contains the current timestamp within a 5 second difference

Scenario: The user passes the wrong number of arguments with "-r" and "-v"
    When the user executes "rback -r -v -- minute 10 120 10 hour 2 2"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase "expected 8"
    And the message contains the current timestamp within a 5 second difference

Scenario: The user passes "-d" and "-v" without "-x"
    Given the directory "${TEMP_TEST_DIR}/files" exists
    When the user executes "rback -v -d -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains '"-x" is required with "-d"'
    And the message contains the current timestamp within a 5 second difference

Scenario: The user passes "-v" with an existing directory conflict
    Given the directory "${TEMP_TEST_DIR}/hour.6.2" exists
    And the directory "${TEMP_TEST_DIR}/minute.120.30" exists
    When the user executes "rback -r -v -- hour 2 2 4 minute 120 30 ${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains "${TEMP_TEST_DIR}/hour.6.2 already exists"
    And the message contains the current timestamp within a 5 second difference

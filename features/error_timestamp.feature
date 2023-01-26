Feature: print timestamps for all error messages with "-v"

Background:
    Given the user has an open terminal with a command line prompt
    And "${TEMP_TEST_DIR}" is a valid path to a directory
    And the rback script is on the path
    And Rsync is intalled


Scenario: The user passes fewer than 6 arguments with "-v"
    When the user executes "run rback -v -- minute 30 30 480 "${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase "at least 6 required"
    And the message contains the current timestamp within a 5 second difference

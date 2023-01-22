Feature: Add command line interface error checking for limit arguments

Background:
    Given the user has an open terminal with a command line prompt
    And "${TEMP_TEST_DIR}" is a valid path to a directory
    And the directory "${TEMP_TEST_DIR}/files" exists"
    And the rback script is on the path
    And Rsync is installed


Scenario: The user enters a limit argument less than the start argument
    When the user executes "rback -- hour 2 2 1 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the error message contains the phrase "START 2 exceeds LIMIT 1"

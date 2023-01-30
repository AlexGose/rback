Feature: Anything can be temporarily appended to snapshot folder names

Background:
    Given the user has an open terminal with a command line prompt
    And "${TEMP_TEST_DIR}" is a valid path to a directory
    And the rback script is on the path
    And Rsync is installed


Scenario: The user copies a snapshot, appends "hello", and rotates snapshots
    Given the directory "${TEMP_TEST_DIR}/minute.120.30" exists
    When the user copies the directory "${TEMP_TEST_DIR}/minute.120.30"
    And the user names the copy "${TEMP_TEST_DIR}/minute.120.30_hello"
    And the user executes "rback -r -- hour 2 2 4 minute 120 30 "${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase "conflicting snapshot names"
    And the message contains "${TEMP_TEST_DIR}/minute.120.30"
    And the message contains "${TEMP_TEST_DIR}/minute.120.30_hello"

Scenario: The user copies a snapshot, appends "hello", and backs up
    Given the directory "${TEMP_TEST_DIR}/hour.2.2" exists
    And the directory "${TEMP_TEST_DIR}/files" exists
    When the user copies the directory "${TEMP_TEST_DIR}/hour.2.2"
    And the user renames the copy "${TEMP_TEST_DIR}hour.2.2_hello"
    And the user executes "rback -- hour 2 2 6 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase "conflicting snapshot names"
    And the message contains "${TEMP_TEST_DIR}/hour.2.2"
    And the message contains "${TEMP_TEST_DIR}/hour.2.2_hello"

Scenario: The user backs up after appending "hello" to limit+interval snapshot
    Given the directory "${TEMP_TEST_DIR}/files" exists
    When the user creates the directory "${TEMP_TEST_DIR}/hour.8.2_hello"
    And the user executes "rback -- hour 2 2 6 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}"
    Then the command fails
    And a message is printed to standard error
    And the message contains the phrase "${TEMP_TEST_DIR}/hour.8.2_hello already exists"

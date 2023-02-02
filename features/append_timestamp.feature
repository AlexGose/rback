Feature: Append timestamp info to all snapshot folder names with "-a"

Background:
    Given the user has an open terminal with a command line prompt
    And "${TEMP_TEST_DIR}" is a valid path to a directory
    And the rback script is on the path
    And Rsync is installed


Scenario: The user backs up with "-a" when no snapshots exist
    Given the snapshot folder "${TEMP_TEST_DIR}/hour.4.4" does not exist
    But the folder "${TEMP_TEST_DIR}/files" does exist
    When the user executes "rback -a -- hour 4 4 12 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}"
    Then the command succeeds
    And the directory "${TEMP_TEST_DIR}/hour.4.4_YYYYMMDD_HHMMSS" exists
    And "YYYYMMDD" and "HHMMSS" is the current timestamp info within 5 seconds

Scenario: The user rotates snapshots with "-a" when no snapshots exist
    Given the directory "${TEMP_TEST_DIR}/hour.4.4" does not exist
    And the directory "${TEMP_TEST_DIR}/hour.8.4" does not exist
    And the directory "${TEMP_TEST_DIR}/hour.12.4" does not exist
    But the directory "${TEMP_TEST_DIR}/minute.240.30" exists
    When the user executes "rback -r -a -- hour 4 4 12 minute 240 30 ${TEMP_TEST_DIR}"
    Then the command succeeds
    And the directory "${TEMP_TEST_DIR}/hour.4.4_YYYYMMDD_HHMMSS" exists
    And "YYYYMMDD" and "HHMMSS" is the current timestamp info within 5 seconds

Scenario: The user backs up with "-a" and snapshots have timestamps
    Given the snapshot folder "${TEMP_TEST_DIR}/hour.2.2" with timestamp appended exists
    And the snapshot folder "${TEMP_TEST_DIR}/hour.4.2" with timestamp appended exists
    And the snapshot folder "${TEMP_TEST_DIR}/hour.6.2" with timestamp appended exists
    And the folder "${TEMP_TEST_DIR}/files" exists
    When the user executes "rback -a -- hour 2 2 6 ${TEMP_TEST_DIR}/files/ ${TEMP_TEST_DIR}"
    Then the command succeeds
    And the directory "${TEMP_TEST_DIR}/hour.2.2_YYYYMMDD_HHMMSS" exists
    And the directory "${TEMP_TEST_DIR}/hour.4.2_YYYYMMDD_HHMMSS" exists
    And the directory "${TEMP_TEST_DIR}/hour.6.2_YYYYMMDD_HHMMSS" exists
    And "YYYYMMDD" and "HHMMSS" is the current timestamp info within 5 seconds in each case

Scenario: The user rotates snapshots with "-a" without appended timestamps
    Given the snapshot folder "${TEMP_TEST_DIR}/hour.2.2" exists
    And the snapshot folder "${TEMP_TEST_DIR}/hour.4.2" exists
    And the snapshot folder "${TEMP_TEST_DIR}/hour.6.2" exists
    And the snapshot folder "${TEMP_TEST_DIR}/minute.120.30" exists
    When the user executes "rback -a -r -- hour 2 2 6 minute 120 30 ${TEMP_TEST_DIR}"
    Then the command succeeds
    And the directory "${TEMP_TEST_DIR}/hour.2.2_YYYYMMDD_HHMMSS" exists
    And the directory "${TEMP_TEST_DIR}/hour.4.2_YYYYMMDD_HHMMSS" exists
    And the directory "${TEMP_TEST_DIR}/hour.6.2_YYYYMMDD_HHMMSS" exists
    And "YYYYMMDD" and "HHMMSS" is the current timestamp info within 5 seconds in each case

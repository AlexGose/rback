Feature: A good README file

Background:
    Given the user downloads or views the project in a browser on GitHub or Gitlab
    And the user opens or views the README file


Scenario: The user reads a brief explanation of the unique value proposition
    When the user views the top of the README file
    Then there is a brief section titled "Introduction"
    And "rback" is described as a Bash script for Rsync backups on Ubuntu 20.04 Linux
    And the collection of features is described as unique
    And "rback" is descrbed as allowing for more complex snapshot folder structures than others
    And an example of a useful complex snapshot folder structure is given
    And the avoidance of storing metadata files is mentioned as a feature
    And detailed metadata in the folder names is described as a feature
    And a list of the detailed metadata is given: elapsed time, update intervals, and timestamps
    And bats-core tests and Gherkin feature files are mentioned as a feature
    And striving to conform to the Google Shell Style Guide (GSSG) is mentioned as a feature
    And every feature mentioned has a benefit describing its value
    And there are hyperlinks for Rsync, Ubuntu 20.04, bats-core, Gherkin, and the GSSG

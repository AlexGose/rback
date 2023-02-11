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

Scenario: The user reads a brief explanation of what Rsync based Bash backups are
    When the user scrolls down the README file
    Then there is a brief section titled "Rsync-based Bash backup scripts"
    And the long history of such scripts is mentioned
    And links to several scripts are provided
    And the continued use and value of such scripts is mentioned
    And an example of a recently developed and popular script is provided

Scenario: The user reads a brief explanation of the features of Rsync based Bash backups
    When the user scrolls down the README file
    Then the simplicity of these scripts is mentioned
    And the portability of Bash is mentioned
    And the speed benefit of Rsync, including to/from remote machines, is mentioned 
    And the familiarity and space savings of hard links is mentioned
    And every feature mentioned has benefits describing its value

Scenario: The user reads a list of features
    When the user scrolls down the README file
    Then there is a bulleted list of features
    And the list includes "free and open source" with a link
    And the list includes other features mentioned in the README

Scenario: The user reads a brief installation guide for Ubuntu 20.04
    When the user scrolls down the README file
    Then there is a section titled "Installation"
    And simply downloading "src/rback" is mentioned
    And cloning the repo is mentioned if the user wants to run the tests

Scenario: The user reads a brief guide for running tests in Docker
    When the user scrolls down the README file
    Then there is mention of how to build the rbacktest Docker image
    And there is mention of how to run the tests in a Docker container

Scenario: The user reads how to run the script as a Cron job
    When the user scrolls down the README file
    Then there is a section titled "Getting Started"
    And instructions for opening the crontab file are given
    And instructions for adding the Cron job are given

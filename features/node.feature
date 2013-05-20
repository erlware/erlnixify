Feature: Node
  In order to manage a running erlang node
  As a developer
  I want to be able to bring it up and shut it down
  and regularly check to see if its still running as expected

  Scenario: Basic startup
    Given a valid configuration
    And the erlang node is started
    When the node is brought up
    Then no errors or problems occur

  Scenario: Startup failure
    Given a valid configuration with invalid command
    And the erlang node is started
    When the node fails
    Then an exception occures

  Scenario: Check failure
    Given a valid configuration with invalid check command
    And the erlang node is started
    When the check fails
    And the erlang node is halted

  Scenario: Check Timeout
    Given a valid configuration with a long running check comamnd
    And the erlang node is started
    When the check command times out
    Then the erlang node is halted

  Scenario: Signal TERM
    Given a valid configuration
    And the erlang node is started
    When a term signal is recieved
    Then the erlang node is halted

Feature: Settings
  In order to provide a 'templatable' settings file
  As a developer
  I want to be able to provide a settings file
  and have the system warn me when I get settings wrong

  Scenario: A basic yaml settings file
    Given a settings file
    When I load that settings file
    Then the settings should be available in the settings object

  Scenario: Command line options override config
    Given an options object that contains config values
    When a new settings file is loaded up using that options
    Then the command line options override the file options

  Scenario: Reasonable Default Settings
    Given a lack of a config file and command line options
    When a settings are loaded
    Then that settings object contains sane defaults

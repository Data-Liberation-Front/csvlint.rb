Feature: Get validation information messages

  Scenario: LF line endings in file give an info message
    Given I have a CSV file called "lf-line-endings.csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are info messages
    Then there should be 1 info message
    And that message should have the type "lf_line_breaks"

  Scenario: Correct line endings in file produces no info messages
    Given I have a CSV with carriage returns in fields
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are info messages
    Then there should be 0 info messages

Feature: Get validation information messages

  Scenario: Incorrect line endings in file
    Given I have a CSV file called "incorrect-line-endings.csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are info messages
    Then there should be 1 info message
    And that message should have the type "line_breaks"

  Scenario: Incorrect line endings in file
    Given I have a CSV with carriage returns in fields
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are info messages
    Then there should be 0 info messages

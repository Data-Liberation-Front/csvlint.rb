Feature: CSV options

  Scenario: Sucessfully parse a valid CSV
    Given I have a CSV with the following content:
    """
'Foo';'Bar';'Baz'
'1';'2';'3'
'3';'2';'1'
    """
    And I set the delimiter to ";"
    And I set quotechar to "'" 
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of true

  Scenario: Warn if options seem to return invalid data
    Given I have a CSV with the following content:
    """
'Foo';'Bar';'Baz'
'1';'2';'3'
'3';'2';'1'
    """
    And I set the delimiter to ","
    And I set quotechar to """ 
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "check_options"

  Scenario: Use esoteric line endings
    Given I have a CSV file called "windows-line-endings.csv"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of true
    
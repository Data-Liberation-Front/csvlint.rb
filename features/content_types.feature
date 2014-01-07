Feature: Content types
  
  Background:
    Given I have a CSV with the following content:
    """
"abc","2","3"
    """
  
  Scenario: Correct content type
    And the content type is set to "text/csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 0 warnings

  Scenario: Incorrect content type
    And the content type is set to "application/excel"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "content_type"
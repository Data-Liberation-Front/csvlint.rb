Feature: Get validation errors

  Scenario: CSV with ragged rows
    Given I have a CSV with the following content:
    """
"1","2","3"
"4","5"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "ragged_rows"
    And that error should have the position "2"
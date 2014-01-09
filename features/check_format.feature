Feature: Check inconsistent formatting

  Scenario: Inconsistent formatting for integers
    Given I have a CSV with the following content:
    """
"1","2","3"
"Foo","5","6"
"3","2","1"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "inconsistent_values"
    And that warning should have the position "2"
    
  Scenario: Inconsistent formatting for alpha fields
    Given I have a CSV with the following content:
    """
"Foo","Bar","Baz"
"Biz","1","Baff"
"Boff","Giff","Goff"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "inconsistent_values"
    And that warning should have the position "2"

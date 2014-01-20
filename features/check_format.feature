Feature: Check inconsistent formatting

  Scenario: Inconsistent formatting for integers
    Given I have a CSV with the following content:
    """
"1","2","3"
"Foo","5","6"
"3","2","1"
"3","2","1"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "inconsistent_values"
    And that warning should have the column "1"
    
  Scenario: Inconsistent formatting for alpha fields
    Given I have a CSV with the following content:
    """
"Foo","Bar","Baz"
"Biz","1","Baff"
"Boff","Giff","Goff"
"Boff","Giff","Goff"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "inconsistent_values"
    And that warning should have the column "2"

  Scenario: Inconsistent formatting for alphanumeric fields
    Given I have a CSV with the following content:
    """
"Foo 123","Bar","Baz"
"1","Bar","Baff"
"Boff 432423","Giff","Goff"
"Boff444","Giff","Goff"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "inconsistent_values"
    And that warning should have the column "1"


    

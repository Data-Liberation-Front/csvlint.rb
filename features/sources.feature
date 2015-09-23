Feature: Parse CSV from Different Sources

  Scenario: Successfully parse a valid CSV from a StringIO
      Given I have a CSV with the following content:
    """
"Foo","Bar","Baz"
"1","2","3"
"3","2","1"
    """
    And it is parsed as a StringIO
    When I ask if the CSV is valid
    Then I should get the value of true

  Scenario: Successfully parse a valid CSV from a File
    Given I parse a file called "valid.csv"
    When I ask if the CSV is valid
    Then I should get the value of true

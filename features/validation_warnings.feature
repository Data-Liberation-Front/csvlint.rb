Feature: Validation warnings

  Scenario: UTF-8 Encoding
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"abc","2","3"
    """
    And it is encoded as "utf-8"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are warnings
    Then there should be 0 warnings

   Scenario: ISO-8859-1 Encoding
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"1","2","3"
    """
     And it is encoded as "iso-8859-1"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are warnings
    Then there should be 1 warnings

  Scenario: Correct content type
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"abc","2","3"
    """
    And the content type is set to "text/csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 0 warnings

  Scenario: No extension
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"abc","2","3"
    """
    And the content type is set to "text/csv"
    And it is stored at the url "http://example.com/example1"
    And I ask if there are warnings
    Then there should be 0 warnings

  Scenario: Allow query params after extension
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"abc","2","3"
    """
    And the content type is set to "text/csv"
    And it is stored at the url "http://example.com/example1.csv?query=param"
    And I ask if there are warnings
    Then there should be 0 warnings

  Scenario: User doesn't supply encoding
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"abc","2","3"
    """
    And it is stored at the url "http://example.com/example1.csv" with no character set
    When I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "no_encoding"

  Scenario: Title rows
    Given I have a CSV file called "title-row.csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "title_row"

  Scenario: catch excel warnings
    Given I parse a file called "spreadsheet.xls"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "excel"

  Scenario: catch excel warnings
    Given I parse a file called "spreadsheet.xlsx"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "excel"

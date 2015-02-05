Feature: Get validation errors

  Scenario: CSV with ragged rows
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"1","2","3"
"4","5"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "ragged_rows"
    And that error should have the row "3"
    And that error should have the content ""4","5""

  Scenario: CSV with incorrect quoting
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"Foo","Bar","Baz
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "unclosed_quote"
    And that error should have the row "2"
    And that error should have the content ""Foo","Bar","Baz"
    
   Scenario: Successfully report a CSV with incorrect whitespace
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"Foo","Bar",   "Baz"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "whitespace"
    And that error should have the row "2"
    And that error should have the content ""Foo","Bar",   "Baz""
    
  Scenario: Successfully report a CSV with blank rows
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"Foo","Bar","Baz"
"","",
"Baz","Bar","Foo"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "blank_rows"
    And that error should have the row "3"
    And that error should have the content ""","","

  Scenario: Successfully report a CSV with multiple trailing empty rows
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"Foo","Bar","Baz"
"Foo","Bar","Baz"


    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "blank_rows"
    And that error should have the row "4"

  Scenario: Successfully report a CSV with an empty row
    Given I have a CSV with the following content:
    """
"col1","col2","col3"
"Foo","Bar","Baz"

"Foo","Bar","Baz"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "blank_rows"
    And that error should have the row "3"
    
  Scenario: Report invalid Encoding
    Given I have a CSV file called "invalid-byte-sequence.csv"
    And I set an encoding header of "UTF-8"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error    
    And that error should have the type "invalid_encoding"
    
  Scenario: Correctly handle different encodings
    Given I have a CSV file called "invalid-byte-sequence.csv"
    And I set an encoding header of "ISO-8859-1"    
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be no "content_encoding" errors  
    
  Scenario: Report invalid file
    
    Given I have a CSV file called "spreadsheet.xls"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error    
    And that error should have the type "invalid_encoding"
    
  Scenario: Incorrect content type
    Given I have a CSV with the following content:
    """
"abc","2","3"
    """
    And the content type is set to "application/excel"
    And it is stored at the url "http://example.com/example1.xls"
    And I ask if there are errors
    Then there should be 1 error
    And that error should have the type "wrong_content_type"

  Scenario: Incorrect extension
    Given I have a CSV with the following content:
    """
"abc","2","3"
    """
    And the content type is set to "application/excel"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are errors
    Then there should be 1 error
    And that error should have the type "wrong_content_type"
    
  Scenario: Handles urls that 404
    Given I have a CSV that doesn't exist
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "not_found"
    
  Scenario: Incorrect line endings specified in settings
    Given I have a CSV file called "cr-line-endings.csv"
    And I set the line endings to linefeed
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are errors
    Then there should be 1 error
    And that error should have the type "line_breaks"
  
  Scenario: inconsistent line endings in file cause an error
    Given I have a CSV file called "inconsistent-line-endings.csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are errors
    Then there should be 1 error
    And that error should have the type "line_breaks"


  Scenario: inconsistent line endings with unquoted fields in file cause an error
    Given I have a CSV file called "inconsistent-line-endings-unquoted.csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are errors
    Then there should be 1 error
    And that error should have the type "line_breaks"

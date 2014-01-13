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
    And that error should have the row "2"
    And that error should have the content ""4","5""

  Scenario: CSV with incorrect quoting
    Given I have a CSV with the following content:
    """
"Foo","Bar","Baz
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "quoting"
    And that error should have the row "1"
    And that error should have the content ""Foo","Bar","Baz"
    
   Scenario: Successfully report a CSV with incorrect whitespace
    Given I have a CSV with the following content:
    """
"Foo","Bar",   "Baz"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "whitespace"
    And that error should have the row "1"
    And that error should have the content ""Foo","Bar",   "Baz""
    
  Scenario: Successfully report a CSV with blank rows
    Given I have a CSV with the following content:
    """
"Foo","Bar","Baz"
"","",
"Baz","Bar","Foo"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "blank_rows"
    And that error should have the row "2"
    And that error should have the content ""","","
    
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
    Then there should be 0 error  
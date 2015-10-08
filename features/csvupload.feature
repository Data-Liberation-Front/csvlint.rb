Feature: Collect all the tests that should trigger dialect check related errors

  Scenario: Title rows, I wish to trigger a :title_row type message
    Given I have a CSV file called "title-row.csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I ask if there are warnings
    Then there should be 1 warnings
    And that warning should have the type "title_row"

#    :nonrfc_line_breaks

  Scenario: LF line endings in file give an info message of type :nonrfc_line_breaks
    Given I have a CSV file called "lf-line-endings.csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I set header to "true"
    And I ask if there are info messages
    Then there should be 1 info message
    And one of the messages should have the type "nonrfc_line_breaks"

  Scenario: CRLF line endings in file produces no info messages of type :nonrfc_line_breaks
    Given I have a CSV file called "crlf-line-endings.csv"
    And it is stored at the url "http://example.com/example1.csv"
    And I set header to "true"
    And I ask if there are info messages
    Then there should be 0 info messages

#  :line_breaks

  Scenario: Incorrect line endings specified in settings
    Given I have a CSV file called "lf-line-endings.csv"
    And I set the line endings to carriage return
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

#:unclosed_quote

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

#  :invalid_encoding

  Scenario: Report invalid Encoding
    Given I have a CSV file called "invalid-byte-sequence.csv"
    And I set an encoding header of "UTF-8"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "invalid_encoding"

  Scenario: Report invalid file
#should this throw an excel error?
    Given I have a CSV file called "spreadsheet.xls"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "invalid_encoding"

#  :blank_rows

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

#:check_options

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

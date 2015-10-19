Feature: CSVlint CLI

  Scenario: Valid CSV from url
    Given I have a CSV with the following content:
    """
"Foo","Bar","Baz"
"1","2","3"
"3","2","1"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I run `csvlint http://example.com/example1.csv`
    Then the output should contain "http://example.com/example1.csv is VALID"
    And the output should contain "..."

  Scenario: Valid CSV from file
    When I run `csvlint ../../features/fixtures/valid.csv`
    Then the output should contain "valid.csv is VALID"
    And the output should contain "..."

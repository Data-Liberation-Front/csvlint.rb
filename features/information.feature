Feature: Return information

  Background:
    Given I have a CSV with the following content:
    """
"abc","2","3"
    """
    And it is encoded as "utf-8"
    And the content type is "text/csv"
    And it is stored at the url "http://example.com/example1.csv?query=true"

  Scenario: Return encoding
    Then the "encoding" should be "UTF-8"

  Scenario: Return content type
    Then the "content_type" should be "text/csv; charset=utf-8"

  Scenario: Return extension
    Then the "extension" should be ".csv"

  Scenario: Return meta
    Then the metadata content type should be "text/csv; charset=utf-8"

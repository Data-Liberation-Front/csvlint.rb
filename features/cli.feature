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

  Scenario: Valid CSV from file
    When I run `csvlint ../../features/fixtures/valid.csv`
    Then the output should contain "valid.csv is VALID"

  # This is a hacky way of saying to run `cat features/fixtures/valid.csv | csvlint`
  Scenario: Valid CSV from pipe
    Given I have stubbed ARGF to contain "features/fixtures/valid.csv"
    When I run `csvlint`
    Then the output should contain "CSV is VALID"

  Scenario: Invalid CSV from url
    Given I have a CSV with the following content:
    """
    "Foo",	"Bar"	,	"Baz"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I run `csvlint http://example.com/example1.csv`
    Then the output should contain "http://example.com/example1.csv is INVALID"
    And the output should contain "whitespace"

  Scenario: Specify schema
    Given I have a CSV with the following content:
    """
"Bob","1234","bob@example.org"
"Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I have a schema with the following content:
    """
{
	"fields": [
          { "name": "Name", "constraints": { "required": true } },
          { "name": "Id", "constraints": { "required": true, "minLength": 1 } },
          { "name": "Email", "constraints": { "required": true } }
    ]
}
    """
    And the schema is stored at the url "http://example.com/schema.json"
    When I run `csvlint http://example.com/example1.csv --schema http://example.com/schema.json`
    Then the output should contain "http://example.com/example1.csv is VALID"

  Scenario: Schema errors
    Given I have a CSV with the following content:
    """
"Bob","1234","bob@example.org"
"Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I have a schema with the following content:
    """
{
  "fields": [
          { "name": "Name", "constraints": { "required": true } },
          { "name": "Id", "constraints": { "required": true, "minLength": 3 } },
          { "name": "Email", "constraints": { "required": true } }
    ]
}
    """
    And the schema is stored at the url "http://example.com/schema.json"
    When I run `csvlint http://example.com/example1.csv --schema http://example.com/schema.json`
    Then the output should contain "http://example.com/example1.csv is INVALID"
    And the output should contain "1. min_length. Row: 2,2. 5"
    And the output should contain "1. malformed_header. Row: 1. Bob,1234,bob@example.org"

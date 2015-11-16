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
    Given I have stubbed stdin to contain "features/fixtures/valid.csv"
    When I run `csvlint`
    Then the output should contain "CSV is VALID"

  Scenario: URL that 404s
    Given there is no file at the url "http://example.com/example1.csv"
    And there is no file at the url "http://example.com/.well-known/csvm"
    And there is no file at the url "http://example.com/example1.csv-metadata.json"
    And there is no file at the url "http://example.com/csv-metadata.json"
    When I run `csvlint http://example.com/example1.csv`
    Then the output should contain "http://example.com/example1.csv is INVALID"
    And the output should contain "not_found"

  Scenario: File doesn't exist
    When I run `csvlint ../../features/fixtures/non-existent-file.csv`
    Then the output should contain "non-existent-file.csv not found"

  Scenario: No file or URL specified
    Given I have stubbed stdin to contain nothing
    When I run `csvlint`
    Then the output should contain "No CSV data to validate"

  Scenario: No file or URL specified, but schema specified
    Given I have stubbed stdin to contain nothing
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
    When I run `csvlint --schema http://example.com/schema.json`
    Then the output should contain "No CSV data to validate"

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
    And the output should contain "1. Id: min_length. Row: 2,2. 5"
    And the output should contain "1. malformed_header. Row: 1. Bob,1234,bob@example.org"

  Scenario: Invalid schema
    Given I have a CSV with the following content:
    """
"Bob","1234","bob@example.org"
"Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I have a schema with the following content:
    """
NO JSON HERE SON
    """
    And the schema is stored at the url "http://example.com/schema.json"
    Then nothing should be outputted to STDERR
    When I run `csvlint http://example.com/example1.csv --schema http://example.com/schema.json`
    And the output should contain "invalid metadata: malformed JSON"

  Scenario: Schema that 404s
    Given I have a CSV with the following content:
    """
"Bob","1234","bob@example.org"
"Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And there is no file at the url "http://example.com/schema404.json"
    When I run `csvlint http://example.com/example1.csv --schema http://example.com/schema404.json`
    Then the output should contain "http://example.com/schema404.json not found"

  Scenario: Schema that doesn't exist
    Given I have a CSV with the following content:
    """
"Bob","1234","bob@example.org"
"Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I run `csvlint http://example.com/example1.csv --schema /fake/file/path.json`
    Then the output should contain "/fake/file/path.json not found"

  Scenario: Valid CSVw schema
    Given I have a CSV with the following content:
    """
"Bob","1234","bob@example.org"
"Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I have metadata with the following content:
    """
{
  "@context": "http://www.w3.org/ns/csvw",
  "url": "http://example.com/example1.csv",
  "dialect": { "header": false },
  "tableSchema": {
    "columns": [
            { "name": "Name", "required": true },
            { "name": "Id", "required": true, "datatype": { "base": "string", "minLength": 1 } },
            { "name": "Email", "required": true }
      ]
  }
}
    """
    And the schema is stored at the url "http://example.com/schema.json"
    When I run `csvlint http://example.com/example1.csv --schema http://example.com/schema.json`
    Then the output should contain "http://example.com/example1.csv is VALID"

  Scenario: CSVw schema with invalid CSV
    Given I have a CSV with the following content:
    """
"Bob","1234","bob@example.org"
"Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I have metadata with the following content:
    """
{
  "@context": "http://www.w3.org/ns/csvw",
  "url": "http://example.com/example1.csv",
  "dialect": { "header": false },
  "tableSchema": {
    "columns": [
            { "name": "Name", "required": true },
            { "name": "Id", "required": true, "datatype": { "base": "string", "minLength": 3 } },
            { "name": "Email", "required": true }
      ]
  }
}
    """
    And the schema is stored at the url "http://example.com/schema.json"
    When I run `csvlint http://example.com/example1.csv --schema http://example.com/schema.json`
    Then the output should contain "http://example.com/example1.csv is INVALID"
    And the output should contain "1. min_length. Row: 2,2. 5"

  Scenario: CSVw table Schema
    Given I have stubbed stdin to contain nothing
    And I have a metadata file called "csvw/countries.json"
    And the metadata is stored at the url "http://w3c.github.io/csvw/tests/countries.json"
    And I have a file called "csvw/countries.csv" at the url "http://w3c.github.io/csvw/tests/countries.csv"
    And I have a file called "csvw/country_slice.csv" at the url "http://w3c.github.io/csvw/tests/country_slice.csv"
    When I run `csvlint --schema http://w3c.github.io/csvw/tests/countries.json`
    Then the output should contain "http://w3c.github.io/csvw/tests/countries.csv is VALID"
    And the output should contain "http://w3c.github.io/csvw/tests/country_slice.csv is VALID"

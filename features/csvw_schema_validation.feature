Feature: CSVW Schema Validation

  Scenario: Valid CSV
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
  "tableSchema": {
    "columns": [
            { "name": "Name", "required": true },
            { "name": "Id", "required": true, "datatype": { "base": "string", "minLength": 1 } },
            { "name": "Email", "required": true }
      ]
  }
}
    """
    When I ask if there are errors
    Then there should be 0 error

  Scenario: Schema invalid CSV
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
  "tableSchema": {
    "columns": [
            { "name": "Name", "required": true },
            { "name": "Id", "required": true, "datatype": { "base": "string", "minLength": 3 } },
            { "name": "Email", "required": true }
      ]
  }
}
    """
    When I ask if there are errors
    Then there should be 1 error

  Scenario: CSV with incorrect header
    Given I have a CSV with the following content:
    """
"name","id","contact"
"Bob","1234","bob@example.org"
"Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I have metadata with the following content:
    """
{
  "@context": "http://www.w3.org/ns/csvw",
  "url": "http://example.com/example1.csv",
  "tableSchema": {
    "columns": [
            { "name": "name", "required": true },
            { "name": "id", "required": true, "datatype": { "base": "string", "minLength": 3 } },
            { "name": "email", "required": true }
      ]
  }
}
    """
    When I ask if there are warnings
    Then there should be 1 warnings

  Scenario: Schema with valid regex
    Given I have a CSV with the following content:
    """
  "firstname","id","email"
  "Bob","1234","bob@example.org"
  "Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I have metadata with the following content:
    """
{
  "@context": "http://www.w3.org/ns/csvw",
  "url": "http://example.com/example1.csv",
  "tableSchema": {
    "columns": [
            { "name": "firstname", "required": true, "datatype": { "base": "string", "format": "^[A-Za-z0-9_]*$" } },
            { "name": "id", "required": true, "datatype": { "base": "string", "minLength": 1 } },
            { "name": "email", "required": true }
      ]
  }
}
    """
    When I ask if there are errors
    Then there should be 0 error

  Scenario: Schema with invalid regex
    Given I have a CSV with the following content:
    """
  "firstname","id","email"
  "Bob","1234","bob@example.org"
  "Alice","5","alice@example.com"
    """
    And it is stored at the url "http://example.com/example1.csv"
    And I have metadata with the following content:
    """
{
  "@context": "http://www.w3.org/ns/csvw",
  "url": "http://example.com/example1.csv",
  "tableSchema": {
    "columns": [
            { "name": "Name", "required": true, "datatype": { "base": "string", "format": "((" } },
            { "name": "Id", "required": true, "datatype": { "base": "string", "minLength": 1 } },
            { "name": "Email", "required": true }
      ]
  }
}
    """
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "invalid_regex"

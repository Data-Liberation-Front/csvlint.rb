Feature: Schema Validation

  Scenario: Valid CSV
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
    When I ask if there are errors
    Then there should be 0 error

  Scenario: Schema invalid CSV
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
    And I have a schema with the following content:
    """
{
	"fields": [
          { "name": "name", "constraints": { "required": true } },
          { "name": "id", "constraints": { "required": true, "minLength": 3 } },
          { "name": "email", "constraints": { "required": true } }
    ]
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
    And I have a schema with the following content:
    """
{
  "fields": [
          { "name": "Name", "constraints": { "required": true, "pattern": "^[A-Za-z0-9_]*$" } },
          { "name": "Id", "constraints": { "required": true, "minLength": 1 } },
          { "name": "Email", "constraints": { "required": true } }
    ]
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
    And I have a schema with the following content:
    """
{
  "fields": [
          { "name": "Name", "constraints": { "required": true, "pattern": "((" } },
          { "name": "Id", "constraints": { "required": true, "minLength": 1 } },
          { "name": "Email", "constraints": { "required": true } }
    ]
}
    """
    When I ask if there are errors
    Then there should be 1 error
    And that error should have the type "invalid_regex"

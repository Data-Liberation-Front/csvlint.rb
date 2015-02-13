Feature: Parse CSV

  Scenario: Successfully parse a valid CSV
    Given I have a CSV with the following content:
    """
"Foo","Bar","Baz"
"1","2","3"
"3","2","1"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of true

   Scenario: Successfully parse a CSV with newlines in quoted fields
    Given I have a CSV with the following content:
    """
"a","b","c"
"d","e","this is
valid"
"a","b","c"
"""
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of true

   Scenario: Successfully parse a CSV with multiple newlines in quoted fields
    Given I have a CSV with the following content:
    """
"a","b","c"
"d","this is
valid","as is this
too"
"""
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of true

  Scenario: Successfully report an invalid CSV
    Given I have a CSV with the following content:
    """
	"Foo",	"Bar"	,	"Baz
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of false

   Scenario: Successfully report a CSV with incorrect quoting
    Given I have a CSV with the following content:
    """
"Foo","Bar","Baz
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of false

   Scenario: Successfully report a CSV with incorrect whitespace
    Given I have a CSV with the following content:
    """
"Foo","Bar",   "Baz"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of false

   Scenario: Successfully report a CSV with ragged rows
    Given I have a CSV with the following content:
    """
"col1","col2","col2"
"1","2","3"
"4","5"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of false

    Scenario: Don't class blank values as inconsistencies
     Given I have a CSV with the following content:
     """
"col1","col2","col3"
"1","2","3"
"4","5","6"
"","7","8"
"9","10","11"
"","12","13"
"","14","15"
"16","17","18"
     """
     And it is stored at the url "http://example.com/example1.csv"
     When I ask if there are warnings
     Then there should be 0 warnings

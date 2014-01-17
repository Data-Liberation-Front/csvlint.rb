Feature: Parse CSV
  
  Scenario: Sucessfully parse a valid CSV
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
"1","2","3"
"4","5"
    """
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if the CSV is valid
    Then I should get the value of false


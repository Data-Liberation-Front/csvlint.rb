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
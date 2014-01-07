# encoding: utf-8

Feature: CSV Encoding

  Scenario: UTF-8 Encoding
    Given I have a CSV with the following content:
    """
"abc","2","3"
    """
    And it is encoded as "utf-8"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are warnings
    Then there should be 0 warnings
    
   Scenario: ISO-8859-1 Encoding
    Given I have a CSV with the following content:
    """
"1","2","3"
    """
    And it is encoded as "iso-8859-1"    
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are warnings
    Then there should be 1 warnings   
    
  Scenario: Return encoding
    Given I have a CSV with the following content:
    """
"abc","2","3"
    """
    And it is encoded as "utf-8"
    And it is stored at the url "http://example.com/example1.csv"
    When I ask for the encoding
    Then I should get "utf-8"
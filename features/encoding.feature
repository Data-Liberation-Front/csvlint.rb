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
    And it should have guessed an encoding of "UTF-8"
    
   Scenario: ISO-8859-1 Encoding
    Given I have a CSV with the following content:
    """
Ernest Edmond WYER,For services to the community in Morton 
"and Hanthorpe, Lincolnshire.",
"(Bourne, Lincolnshire)",
"Gwenyth Anne, Mrs YARKER","Curator and Trustee, Dorset County "
Museum.  For services to Museums.,
"(Dorchester, Dorset)",
"Eileen, Mrs YOUNGHUSBAND",For services to Lifelong Learning in Cardiff
 and the Vale of Glamorgan.,
"(Penarth, South Glamorgan)",
    """
    And it is encoded as "iso-8859-1"    
    And it is stored at the url "http://example.com/example1.csv"
    When I ask if there are warnings
    Then there should be 1 warnings   
    And it should have guessed an encoding of "ISO-8859-1"
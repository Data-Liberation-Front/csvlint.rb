require 'set'
require 'date'

module Csvlint
  
  module Types
    
    SIMPLE_FORMATS = {
      'http://www.w3.org/2001/XMLSchema#string'  => lambda { |value, constraints| value },
      'http://www.w3.org/2001/XMLSchema#int'     => lambda { |value, constraints| Integer value },
      'http://www.w3.org/2001/XMLSchema#anyURI'  => lambda do |value, constraints|
        u = URI.parse value
        raise ArgumentError unless u.kind_of?(URI::HTTP) || u.kind_of?(URI::HTTPS)
        u
      end,
      'http://www.w3.org/2001/XMLSchema#dateTime' => lambda do |value, constraints|
        date_pattern = constraints["datePattern"] || "%Y-%m-%dT%H:%M:%SZ"
        d = DateTime.strptime(value, date_pattern)
        raise ArgumentError unless d.strftime(date_pattern) == value
        d
      end,
      'http://www.w3.org/2001/XMLSchema#date' => lambda do |value, constraints|
        date_pattern = constraints["datePattern"] || "%Y-%m-%d"
        d = Date.strptime(value, date_pattern)
        raise ArgumentError unless d.strftime(date_pattern) == value
        d
      end,
      'http://www.w3.org/2001/XMLSchema#time' => lambda do |value, constraints|
        date_pattern = constraints["datePattern"] || "%H:%M:%S"
        d = DateTime.strptime(value, date_pattern)
        raise ArgumentError unless d.strftime(date_pattern) == value
        d
      end,    
    }
    
    TYPE_VALIDATIONS = SIMPLE_FORMATS.merge({
        'http://www.w3.org/2001/XMLSchema#double'   => lambda { |value, constraints| Float value },
        'http://www.w3.org/2001/XMLSchema#float'   => lambda { |value, constraints| Float value },
        'http://www.w3.org/2001/XMLSchema#nonPositiveInteger' => lambda do |value, constraints|
          i = Integer value
          raise ArgumentError unless i <= 0
          i
        end,
        'http://www.w3.org/2001/XMLSchema#boolean' => lambda do |value, constraints|
          return true if ['true', '1'].include? value
          return false if ['false', '0'].include? value
          raise ArgumentError
        end,
        'http://www.w3.org/2001/XMLSchema#negativeInteger' => lambda do |value, constraints|
          i = Integer value
          raise ArgumentError unless i < 0
          i
        end,
        'http://www.w3.org/2001/XMLSchema#nonNegativeInteger' => lambda do |value, constraints|
          i = Integer value
          raise ArgumentError unless i >= 0
          i
        end,
        'http://www.w3.org/2001/XMLSchema#positiveInteger' => lambda do |value, constraints|
          i = Integer value
          raise ArgumentError unless i > 0
          i
        end,
        'http://www.w3.org/2001/XMLSchema#gYear' => lambda do |value, constraints|
          date_pattern = constraints["datePattern"] || "%Y"
          d = Date.strptime(value, date_pattern)
          raise ArgumentError unless d.strftime(date_pattern) == value
          d
        end,     
        'http://www.w3.org/2001/XMLSchema#gYearMonth' => lambda do |value, constraints|
          date_pattern = constraints["datePattern"] || "%Y-%m"
          d = Date.strptime(value, date_pattern)
          raise ArgumentError unless d.strftime(date_pattern) == value
          d
        end 
    })
    
  end

end
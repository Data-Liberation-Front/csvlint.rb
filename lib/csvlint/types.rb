require 'set'
require 'date'
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/time/conversions'
require 'pry'

module Csvlint
  
  module Types
    
    SIMPLE_FORMATS = {
      'string'  => lambda { |value, constraints| value },
      'numeric'     => lambda do |value, constraints| 
        begin
          Integer value 
        rescue ArgumentError
          Float value
        end
      end,
      'uri'  => lambda do |value, constraints|
        u = URI.parse value
        raise ArgumentError unless u.kind_of?(URI::HTTP) || u.kind_of?(URI::HTTPS)
        u
      end
    }
    
    def self.date_format(klass = DateTime, value, type)
      date = klass.strptime(value, klass::DATE_FORMATS[type])
      raise ArgumentError unless date.to_formatted_s(type) == value
    end
    
    def self.included(base)
      Time::DATE_FORMATS[:iso8601] = "%Y-%m-%dT%H:%M:%SZ"
      Time::DATE_FORMATS[:hms] = "%H:%M:%S"
      
      Date::DATE_FORMATS.each do |type|
        SIMPLE_FORMATS["date_#{type.first}"] = lambda do |value, constraints|
          date_format(Date, value, type.first)
        end
      end
    
      Time::DATE_FORMATS.each do |type|
        SIMPLE_FORMATS["dateTime_#{type.first}"] = lambda do |value, constraints|
          date_format(Time, value, type.first)
        end
      end
    end
        
    TYPE_VALIDATIONS = {
        'http://www.w3.org/2001/XMLSchema#string'  => SIMPLE_FORMATS['string'],
        'http://www.w3.org/2001/XMLSchema#int'     => lambda { |value, constraints| Integer value },
        'http://www.w3.org/2001/XMLSchema#float'   => lambda { |value, constraints| Float value },
        'http://www.w3.org/2001/XMLSchema#double'   => lambda { |value, constraints| Float value },
        'http://www.w3.org/2001/XMLSchema#anyURI'  => SIMPLE_FORMATS['uri'],
        'http://www.w3.org/2001/XMLSchema#boolean' => lambda do |value, constraints|
          return true if ['true', '1'].include? value
          return false if ['false', '0'].include? value
          raise ArgumentError
        end,
        'http://www.w3.org/2001/XMLSchema#nonPositiveInteger' => lambda do |value, constraints|
          i = Integer value
          raise ArgumentError unless i <= 0
          i
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
    }
  end

end
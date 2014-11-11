require 'set'
require 'date'
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/time/conversions'

module Csvlint
  module Types
    SIMPLE_FORMATS = {
      'string' => lambda { |value| true },
      'numeric' => lambda { |value| value.strip[/\A[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?\z/] },
      'uri' => lambda do |value|
        if value.strip[/\Ahttps?:/]
          u = URI.parse(value)
          u.kind_of?(URI::HTTP) || u.kind_of?(URI::HTTPS)
        end
      end
    }

    def self.date_format(klass, value, format, pattern)
      if value[pattern]
        klass.strptime(value, format).strftime(format) == value
      end
    end

    def self.included(base)
      [
        [ :db, "%Y-%m-%d",
               /\A\d{4,}-\d\d-\d\d\z/],
        [ :number, "%Y%m%d",
                   /\A\d{8}\z/],
        [ :short, "%e %b",
                  /\A[ \d]\d (?:#{Date::ABBR_MONTHNAMES.join('|')})\z/],
        [ :rfc822, "%e %b %Y",
                   /\A[ \d]\d (?:#{Date::ABBR_MONTHNAMES.join('|')}) \d{4,}\z/],
        [ :long, "%B %e, %Y",
                 /\A(?:#{Date::MONTHNAMES.join('|')}) [ \d]\d, \d{4,}\z/],
      ].each do |type,format,pattern|
        SIMPLE_FORMATS["date_#{type}"] = lambda do |value|
          date_format(Date, value, format, pattern)
        end
      end

      # strptime doesn't support widths like %9N, unlike strftime.
      # @see http://ruby-doc.org/stdlib-2.0/libdoc/date/rdoc/DateTime.html
      [
        [ :time,    "%H:%M",
                    /\A\d\d:\d\d\z/],
        [ :hms,     "%H:%M:%S",
                    /\A\d\d:\d\d:\d\d\z/],
        [ :db,      "%Y-%m-%d %H:%M:%S",
                    /\A\d{4,}-\d\d-\d\d \d\d:\d\d:\d\d\z/],
        [ :iso8601, "%Y-%m-%dT%H:%M:%SZ",
                    /\A\d{4,}-\d\d-\d\dT\d\d:\d\d:\d\dZ\z/],
        [ :number,  "%Y%m%d%H%M%S",
                    /\A\d{14}\z/],
        [ :nsec,    "%Y%m%d%H%M%S%N",
                    /\A\d{23}\z/],
        [ :short,   "%d %b %H:%M",
                    /\A\d\d (?:#{Date::ABBR_MONTHNAMES.join('|')}) \d\d:\d\d\z/],
        [ :long,    "%B %d, %Y %H:%M",
                    /\A(?:#{Date::MONTHNAMES.join('|')}) \d\d, \d{4,} \d\d:\d\d\z/],
      ].each do |type,format,pattern|
        SIMPLE_FORMATS["dateTime_#{type}"] = lambda do |value|
          date_format(Time, value, format, pattern)
        end
      end
    end

    TYPE_VALIDATIONS = {
        'http://www.w3.org/2001/XMLSchema#string'  => lambda { |value, constraints| value },
        'http://www.w3.org/2001/XMLSchema#int'     => lambda { |value, constraints| Integer value },
        'http://www.w3.org/2001/XMLSchema#integer' => lambda { |value, constraints| Integer value },
        'http://www.w3.org/2001/XMLSchema#float'   => lambda { |value, constraints| Float value },
        'http://www.w3.org/2001/XMLSchema#double'   => lambda { |value, constraints| Float value },
        'http://www.w3.org/2001/XMLSchema#anyURI'  => lambda do |value, constraints|
          u = URI.parse value
          raise ArgumentError unless u.kind_of?(URI::HTTP) || u.kind_of?(URI::HTTPS)
          u
        end,
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
        end,
    }
  end
end

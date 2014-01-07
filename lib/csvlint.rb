require "csvlint/version"
require 'csv'
require 'open-uri'

module Csvlint
  
  class Validator
    
    attr_reader :errors, :warnings, :encoding
    
    ERROR_MATCHERS = {
      "Missing or stray quote" => :quoting,
      "Illegal quoting" => :whitespace,
      "Unclosed quoted field" => :quoting,
    }
       
    def initialize(stream)
      @errors = []
      @warnings = []
      @stream = stream
      validate
    end
    
    def valid?
      errors.empty?
    end
    
    def validate
      expected_columns = 0
      current_line = 0
      open(@stream) do |s|
        @encoding = s.charset rescue nil
        if @encoding != "utf-8"
          build_warnings(:encoding, nil)
        end
        s.each_line do |line|
          begin
            current_line = current_line + 1
            row = CSV.parse( line )[0]
            expected_columns = row.count unless expected_columns != 0
            if row.count != expected_columns
              build_errors(:ragged_rows, current_line)
            end
          rescue CSV::MalformedCSVError => e
            type = fetch_error(e)
            build_errors(type, current_line)
          end
        end
      end
      true
    end
    
    def build_errors(type, position)
      @errors << {
        :type => type,
        :position => position
      }
    end
    
    def build_warnings(type, position)
      @warnings << {
        :type => type,
        :position => position
      }
    end
    
    def fetch_error(error)
      e = error.message.match(/^([a-z ]+) (i|o)n line ([0-9]+)\.$/i)
      ERROR_MATCHERS.fetch(e[1], :unknown_error)
    end
    
  end
end

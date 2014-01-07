require "csvlint/version"
require 'csv'
require 'open-uri'

module Csvlint
  
  class Validator
       
    def initialize(stream)
      @stream = stream
    end
    
    def valid?
      begin
        expected_columns = 0
        open(@stream) do |s|
          s.each_line do |line|
            row = CSV.parse( line )[0]
            expected_columns = row.count unless expected_columns != 0
            return false if row.count != expected_columns
          end
        end
        true
      rescue CSV::MalformedCSVError
        false
      end
    end
    
  end
end

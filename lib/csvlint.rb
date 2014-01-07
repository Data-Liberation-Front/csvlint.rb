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
        open(@stream) do |s|
          s.each_line do |line|
            row = CSV.parse( line )
          end
        end
        true
      rescue CSV::MalformedCSVError
        false
      end
    end
    
  end
end

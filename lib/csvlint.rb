require "csvlint/version"
require 'csv'
require 'open-uri'
require 'charlock_holmes'

module Csvlint
  
  class Validator
    
    attr_reader :errors, :warnings, :encoding, :content_type, :guessed_encoding
    
    ENCODING_SAMPLE_SIZE=10
    
    ERROR_MATCHERS = {
      "Missing or stray quote" => :quoting,
      "Illegal quoting" => :whitespace,
      "Unclosed quoted field" => :quoting,
    }
       
    def initialize(stream)
      @errors = []
      @warnings = []
      @stream = stream
      @encoding_sample = []
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
        @content_type = s.content_type rescue nil
        build_warnings(:encoding, nil) if @encoding != "utf-8"
        build_warnings(:content_type, nil) unless @content_type =~ /text\/csv|application\/csv|text\/comma-separated-values/
        s.each_line do |line|
          begin
            current_line = current_line + 1
            @encoding_sample << line if current_line <= ENCODING_SAMPLE_SIZE
            row = CSV.parse( line )[0]
            expected_columns = row.count unless expected_columns != 0
            build_errors(:ragged_rows, current_line) if row.count != expected_columns
            build_errors(:blank_rows, current_line) if row.reject{ |c| c.nil? || c.empty? }.count == 0
          rescue CSV::MalformedCSVError => e
            type = fetch_error(e)
            build_errors(type, current_line)
          end
        end
      end
      guess_encoding()
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
    
    def guess_encoding()      
      contents = @encoding_sample.join()
      puts contents
      begin
        detection = CharlockHolmes::EncodingDetector.detect(contents)
        @guessed_encoding = {
          :encoding => detection[:encoding],
          :confidence => detection[:confidence]
        }
      rescue
      end
    end
    
  end

end

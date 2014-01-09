require "csvlint/version"
require 'csv'
require 'open-uri'

module Csvlint
  
  class Validator
    
    attr_reader :errors, :warnings, :encoding, :content_type, :extension
    
    ERROR_MATCHERS = {
      "Missing or stray quote" => :quoting,
      "Illegal quoting" => :whitespace,
      "Unclosed quoted field" => :quoting,
    }
       
    def initialize(stream, dialect = nil)
      @errors = []
      @warnings = []
      @stream = stream
      @extension = File.extname(@stream)
      @csv_options = dialect_to_csv_options(dialect)
      @csv_options[:row_sep] == nil ? @line_terminator = $/ : @line_terminator = @csv_options[:row_sep]
      validate
    end
    
    def valid?
      errors.empty?
    end
    
    def validate
      expected_columns = 0
      current_line = 0
      single_col = false
      build_warnings(:extension, nil) unless @extension == ".csv"
      open(@stream) do |s|
        @encoding = s.charset
        @content_type = s.content_type
        if s.meta["content-type"] !~ /charset/
          build_warnings(:encoding_not_set, nil) 
        else
          build_warnings(:encoding, nil) if @encoding != "utf-8"
        end
        build_warnings(:content_type, nil) unless @content_type =~ /text\/csv|application\/csv|text\/comma-separated-values/
        s.each_line(@line_terminator) do |line|
          begin
            current_line = current_line + 1
            row = CSV.parse(line.chomp(@line_terminator), @csv_options)[0]
            single_col = true if row.count == 1
            expected_columns = row.count unless expected_columns != 0
            build_errors(:ragged_rows, current_line) if row.count != expected_columns
            build_errors(:blank_rows, current_line) if row.reject{ |c| c.nil? || c.empty? }.count == 0
          rescue CSV::MalformedCSVError => e
            type = fetch_error(e)
            build_errors(type, current_line)
          end
        end
      end
      build_warnings(:check_options, nil) if single_col == true
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
    
    def dialect_to_csv_options(dialect)
        return {} unless dialect
        #supplying defaults here just in case the dialect is invalid
        delimiter = dialect["delimiter"] || ","
        skipinitialspace = dialect["skipinitialspace"] || true
        delimiter = delimiter + " " if !skipinitialspace
        return {
            :col_sep => delimiter,
            :row_sep => ( dialect["lineterminator"] || nil ),
            :quote_char => ( dialect["quotechar"] || '"')
        }
    end
    
  end

end
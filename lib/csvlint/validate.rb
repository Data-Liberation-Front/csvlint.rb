module Csvlint
  
  class Validator
    
    attr_reader :errors, :warnings, :encoding, :content_type, :extension, :headers
    
    ERROR_MATCHERS = {
      "Missing or stray quote" => :quoting,
      "Illegal quoting" => :whitespace,
      "Unclosed quoted field" => :quoting,
    }
       
    def initialize(url, dialect = nil)      
      @errors = []
      @warnings = []
      @url = url
      @extension = parse_extension(url)
      @csv_options = dialect_to_csv_options(dialect)
      @csv_options[:row_sep] == nil ? @line_terminator = $/ : @line_terminator = @csv_options[:row_sep]
      @formats = []
      validate
    end
    
    def valid?
      errors.empty?
    end
    
    def validate
      expected_columns = 0
      current_line = 0
      single_col = false
      reported_invalid_encoding = false
      open(@url) do |s|
        @encoding = s.charset rescue nil
        @content_type = s.content_type rescue nil
        @headers = s.meta        
        mime_types = MIME::Types.type_for(@url)
        if mime_types.count > 0 && mime_types.select { |m| @content_type == m.content_type }.count == 0
          build_warnings(:extension, nil)
        end
        if @headers["content-type"] !~ /charset=/
          build_warnings(:no_encoding, nil) 
        else
          build_warnings(:encoding, nil) if @encoding != "utf-8"
        end
        build_warnings(:content_type, nil) unless @content_type =~ /text\/csv/
        s.each_line(@line_terminator) do |line|
          begin
            current_line = current_line + 1
            @csv_options[:encoding] = @encoding
            row = CSV.parse(line.chomp(@line_terminator), @csv_options)[0]
            build_formats(row, current_line)
            single_col = true if row.count == 1
            expected_columns = row.count unless expected_columns != 0
            build_errors(:ragged_rows, current_line, line) if row.count != expected_columns
            build_errors(:blank_rows, current_line, line) if row.reject{ |c| c.nil? || c.empty? }.count == 0
          rescue CSV::MalformedCSVError => e
            type = fetch_error(e)
            build_errors(type, current_line, line)
          rescue ArgumentError => ae
            build_errors(:invalid_encoding, current_line, line) unless reported_invalid_encoding
            reported_invalid_encoding = true
          end
        end
      end
      check_consistency      
      build_warnings(:check_options, nil) if single_col == true
    end
    
    def build_message(type, row, content)
      Csvlint::ErrorMessage.new({
                                  :type => type,
                                  :row => row,
                                  :content => content
                                })
    end
    
    def build_errors(type, row = nil, content = nil)
      @errors << build_message(type, row, content)
    end
    
    def build_warnings(type, row = nil, content = nil)
      @warnings << build_message(type, row, content)
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
            :quote_char => ( dialect["quotechar"] || '"'),
        }
    end
    
    def build_formats(row, line) 
      row.each_with_index do |col, i|
        @formats[i] ||= []
        
        case col
          when /^[0-9]+$/
            @formats[i] << :numeric
          when /^[a-z0-9 *[\]\[!"#\$%&'()*+,.\/:;<=>?@\^_`{|}~-]]+$/i
            @formats[i] << :alphanumeric
          else
            @formats[i] << :unknown
          end
      end
    end
    
    def check_consistency
      percentages = []
                
      formats = [:numeric, :alpha, :unknown, :alphanumeric]
            
      formats.each do |type, regex|
        @formats.count.times do |i|
          percentages[i] ||= {}
          unless @formats[i].nil?
            percentages[i][type] = @formats[i].grep(/^#{type}$/).count.to_f / @formats[i].count.to_f
          end
        end
      end
      
      percentages.each do |col|
        build_warnings(:inconsistent_values, nil) if col.values.max < 0.9
      end
    end
    
    private
    
    def parse_extension(url)
      parsed = URI.parse(url)
      File.extname(parsed.path)
    end
    
  end
end
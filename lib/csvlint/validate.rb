module Csvlint
  
  class Validator
    
    include Csvlint::ErrorCollector
    
    attr_reader :encoding, :content_type, :extension, :headers
    
    ERROR_MATCHERS = {
      "Missing or stray quote" => :quoting,
      "Illegal quoting" => :whitespace,
      "Unclosed quoted field" => :quoting,
    }
       
    def initialize(source, dialect = nil, schema = nil)      
      @source = source
      @formats = []
      @schema = schema  
      @csv_options = dialect_to_csv_options(dialect)
      @csv_options[:row_sep] == nil ? @line_terminator = $/ : @line_terminator = @csv_options[:row_sep]
        
      @extension = parse_extension(source)
      reset
      validate
    end
        
    def validate
      single_col = false   
      io = nil   
      begin
        io = @source.respond_to?(:gets) ? @source : open(@source)
        validate_metadata(io)
        columns = parse_csv(io)
        build_warnings(:check_options, nil) if columns == 1        
        check_consistency      
      rescue OpenURI::HTTPError, Errno::ENOENT
        build_errors(:not_found)
      ensure
        io.close if io && io.respond_to?(:close)
      end
    end
    
    def validate_metadata(io)
      @encoding = io.charset rescue nil
      @content_type = io.content_type rescue nil
      @headers = io.meta rescue nil    
      if @headers 
        if @headers["content-type"] !~ /charset=/
          build_warnings(:no_encoding) 
        else
          build_warnings(:encoding) if @encoding != "utf-8"
        end
        build_warnings(:no_content_type) if @content_type == nil
        build_warnings(:excel) if @content_type == nil && @extension =~ /.xls(x)?/
        build_errors(:wrong_content_type) unless (@content_type && @content_type =~ /text\/csv/)
      end
      build_errors(:line_breaks) unless @line_terminator == "\r\n"
    end
    
    def parse_csv(io)
      expected_columns = 0
      current_line = 0
      reported_invalid_encoding = false
      
      @csv_options[:encoding] = @encoding  
  
      wrapper = WrappedIO.new( io )        
      csv = CSV.new( wrapper , @csv_options )
      row = nil
      loop do
         current_line = current_line + 1
         begin
           row = csv.shift
           wrapper.finished
           if row
             build_formats(row, current_line)
             expected_columns = row.count unless expected_columns != 0
             build_errors(:ragged_rows, current_line, nil, wrapper.line) if !row.empty? && row.count != expected_columns
             build_errors(:blank_rows, current_line, nil, wrapper.line) if row.reject{ |c| c.nil? || c.empty? }.count == 0
             
             if @schema
               @schema.validate_row(row, current_line)
               @errors += @schema.errors
               @warnings += @schema.warnings
             end
               
           else             
             break
           end         
         rescue CSV::MalformedCSVError => e
           wrapper.finished
           type = fetch_error(e)
           if type == :quoting && wrapper.line.match(/[^\r]\n/)
             build_errors(:line_breaks)
           else
             build_errors(type, current_line, nil, wrapper.line)
           end
         rescue ArgumentError => ae
           wrapper.finished           
           build_errors(:invalid_encoding, current_line, wrapper.line) unless reported_invalid_encoding
           reported_invalid_encoding = true
         end
      end
      return expected_columns        
    end          
    
    
    def fetch_error(error)
      return :quoting if error.message.start_with?("Unquoted fields do not allow")
      e = error.message.match(/^([a-z ]+) (i|o)n line ([0-9]+)\.?$/i)
      ERROR_MATCHERS.fetch(e[1], :unknown_error)
    end
    
    def dialect_to_csv_options(dialect)
        dialect ||= {}
        #supplying defaults here just in case the dialect is invalid        
        delimiter = dialect["delimiter"] || ","
        skipinitialspace = dialect["skipInitialSpace"] || true
        delimiter = delimiter + " " if !skipinitialspace
        return {
            :col_sep => delimiter,
            :row_sep => ( dialect["lineTerminator"] || "\r\n" ),
            :quote_char => ( dialect["quoteChar"] || '"'),
            :skip_blanks => false
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
      
      percentages.each_with_index do |col, i|
        build_warnings(:inconsistent_values, nil, i+1) if col.values.max < 0.9
      end
    end
    
    private
    
    def parse_extension(source)
      case source
      when File
        return File.extname( source.path )
      when IO
        return ""
      when StringIO
        return ""
      else
        parsed = URI.parse(source)
        File.extname(parsed.path)
      end
    end
    
  end
end
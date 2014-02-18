require "open_uri_redirections"

module Csvlint
  
  class Validator
    
    include Csvlint::ErrorCollector
    
    attr_reader :encoding, :content_type, :extension, :headers, :line_breaks, :dialect, :csv_header, :schema
    
    ERROR_MATCHERS = {
      "Missing or stray quote" => :stray_quote,
      "Illegal quoting" => :whitespace,
      "Unclosed quoted field" => :unclosed_quote,
    }
       
    def initialize(source, dialect = {}, schema = nil)      
      @source = source
      @formats = []
      @schema = schema
      
      @dialect = dialect_defaults = {
        "header" => true,
        "delimiter" => ",",
        "skipInitialSpace" => true,
        "lineTerminator" => :auto,
        "quoteChar" => '"'
      }.merge(dialect || {})
            
      @csv_header = true
      @csv_header = @dialect["header"] if @dialect["header"] != nil
        
      @csv_options = dialect_to_csv_options(@dialect)
      @extension = parse_extension(source)
      reset
      validate
    end
        
    def validate
      single_col = false   
      io = nil   
      begin
        io = @source.respond_to?(:gets) ? @source : open(@source, :allow_redirections=>:all)
        validate_metadata(io)
        columns = parse_csv(io)
        build_warnings(:check_options, :structure) if columns == 1        
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
        if @headers["content-type"] =~ /header=(present|absent)/
          @csv_header = true if $1 == "present"
          @csv_header = false if $1 == "absent"
        end
        if @headers["content-type"] !~ /charset=/
          build_warnings(:no_encoding, :context) 
        else
          build_warnings(:encoding, :context) if @encoding != "utf-8"
        end
        build_warnings(:no_content_type, :context) if @content_type == nil
        build_warnings(:excel, :context) if @content_type == nil && @extension =~ /.xls(x)?/
        build_errors(:wrong_content_type, :context) unless (@content_type && @content_type =~ /text\/csv/)
      end
      build_errors(:no_header, :structure) unless @csv_header
    end
    
    def parse_csv(io)
      expected_columns = 0
      current_line = 0
      reported_invalid_encoding = false
      
      @csv_options[:encoding] = @encoding  
  
      begin
        wrapper = WrappedIO.new( io )
        csv = CSV.new( wrapper, @csv_options )
        @line_breaks = csv.row_sep
        if @line_breaks != "\r\n"
          build_info_messages(:nonrfc_line_breaks, :structure)
        end
        row = nil
        loop do
         current_line = current_line + 1
         begin
           row = csv.shift
           wrapper.finished
           if row             
             if header? && current_line == 1
               validate_header(row)
             else
               
               build_formats(row, current_line)
               expected_columns = row.count unless expected_columns != 0
               build_errors(:ragged_rows, :structure, current_line, nil, wrapper.line) if !row.empty? && row.count != expected_columns
               build_errors(:blank_rows, :structure, current_line, nil, wrapper.line) if row.reject{ |c| c.nil? || c.empty? }.count == 0
               
               if @schema
                 @schema.validate_row(row, current_line)
                 @errors += @schema.errors
                 @warnings += @schema.warnings
               end
               
             end
           else             
             break
           end         
         rescue CSV::MalformedCSVError => e
           wrapper.finished
           type = fetch_error(e)
           if type == :stray_quote && !wrapper.line.match(csv.row_sep)
             build_errors(:line_breaks, :structure)
           else
             build_errors(type, :structure, current_line, nil, wrapper.line)
           end
         end
      end
      rescue ArgumentError => ae
        wrapper.finished           
        build_errors(:invalid_encoding, :structure, current_line, wrapper.line) unless reported_invalid_encoding
        reported_invalid_encoding = true
      end
      return expected_columns        
    end          
    
    def validate_header(header)
      names = Set.new
      header.each_with_index do |name,i|
        build_errors(:empty_column_name, :schema, nil, i+1) if name == ""
        if names.include?(name)
          build_errors(:duplicate_column_name, :schema, nil, i+1)
        else
          names << name
        end
      end
      if @schema
        @schema.validate_header(header)
        @errors += @schema.errors
        @warnings += @schema.warnings
      end
      return valid?
    end
    
    def header?
      return @csv_header
    end
    
    def fetch_error(error)
      e = error.message.match(/^([a-z ]+) (i|o)n line ([0-9]+)\.?$/i)
      ERROR_MATCHERS.fetch(e[1], :unknown_error)
    end
    
    def dialect_to_csv_options(dialect) 
        skipinitialspace = dialect["skipInitialSpace"] || true
        delimiter = dialect["delimiter"]
        delimiter = delimiter + " " if !skipinitialspace
        return {
            :col_sep => delimiter,
            :row_sep => dialect["lineTerminator"],
            :quote_char => dialect["quoteChar"],
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
        build_warnings(:inconsistent_values, :schema, nil, i+1) if col.values.max < 0.9
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
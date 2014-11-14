require "open_uri_redirections"

module Csvlint
  
  class Validator
    
    include Csvlint::ErrorCollector
    include Csvlint::Types
    
    attr_reader :encoding, :content_type, :extension, :headers, :line_breaks, :dialect, :csv_header, :schema, :data
    
    ERROR_MATCHERS = {
      "Missing or stray quote" => :stray_quote,
      "Illegal quoting" => :whitespace,
      "Unclosed quoted field" => :unclosed_quote,
    }
       
    def initialize(source, dialect = nil, schema = nil)      
      @source = source
      @formats = []
      @schema = schema
      
      @supplied_dialect = dialect != nil
            
      @dialect = {
        "header" => true,
        "delimiter" => ",",
        "skipInitialSpace" => true,
        "lineTerminator" => :auto,
        "quoteChar" => '"'
      }.merge(dialect || {})
            
      @csv_header = @dialect["header"]
        
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
        parse_csv(io)
        sum = @col_counts.inject(:+)
        unless sum.nil?
          build_warnings(:title_row, :structure) if @col_counts.first < (sum / @col_counts.size.to_f)
        end
        build_warnings(:check_options, :structure) if @expected_columns == 1        
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
      assumed_header = undeclared_header = !@supplied_dialect
      if @headers
        if @headers["content-type"] =~ /text\/csv/
          @csv_header = true
          undeclared_header = false
          assumed_header = true
        end
        if @headers["content-type"] =~ /header=(present|absent)/
          @csv_header = true if $1 == "present"
          @csv_header = false if $1 == "absent"
          undeclared_header = false
          assumed_header = false
        end
        if @headers["content-type"] !~ /charset=/
          build_warnings(:no_encoding, :context) 
        else
          build_warnings(:encoding, :context) if @encoding != "utf-8"
        end
        build_warnings(:no_content_type, :context) if @content_type == nil
        build_warnings(:excel, :context) if @content_type == nil && @extension =~ /.xls(x)?/
        build_errors(:wrong_content_type, :context) unless (@content_type && @content_type =~ /text\/csv/)
        
        if undeclared_header
          build_errors(:undeclared_header, :structure)
          assumed_header = false
        end
        
      end
      build_info_messages(:assumed_header, :structure) if assumed_header
    end
    
    def parse_csv(io)
      @expected_columns = 0
      current_line = 0
      reported_invalid_encoding = false
      @col_counts = []
      
      @csv_options[:encoding] = @encoding  
  
      begin
        csv = FastCSV.new(io, @csv_options)
        @data = []
        @line_breaks = csv.row_sep
        if @line_breaks != "\r\n"
          build_info_messages(:nonrfc_line_breaks, :structure)
        end
        row = nil
        loop do
         current_line = current_line + 1
         begin
           row = csv.shift
           @data << row
           if row             
             if current_line == 1 && header?
               row = row.reject {|r| r.blank? }
               validate_header(row)
               @col_counts << row.size
             else               
               build_formats(row, current_line)
               @col_counts << row.reject {|r| r.blank? }.size
               @expected_columns = row.size unless @expected_columns != 0
               
               build_errors(:blank_rows, :structure, current_line, nil, csv.row) if row.reject{ |c| c.nil? || c.empty? }.size == 0
               
               if @schema
                 @schema.validate_row(row, current_line)
                 @errors += @schema.errors
                 @warnings += @schema.warnings
               else
                 build_errors(:ragged_rows, :structure, current_line, nil, csv.row) if !row.empty? && row.size != @expected_columns
               end
               
             end
           else             
             break
           end         
         rescue FastCSV::MalformedCSVError => e
           type = fetch_error(e)
           if type == :stray_quote && !csv.row.match(@line_breaks)
             build_errors(:line_breaks, :structure)
           else
             build_errors(type, :structure, current_line, nil, csv.row)
           end
         end
      end
      rescue ArgumentError, FastCSV::MalformedCSVError => ae
        build_errors(:invalid_encoding, :structure, current_line, csv && csv.row || "") unless reported_invalid_encoding
        reported_invalid_encoding = true
      end
    end          
    
    def validate_header(header)
      names = Set.new
      header.each_with_index do |name,i|
        build_warnings(:empty_column_name, :schema, nil, i+1) if name == ""
        if names.include?(name)
          build_warnings(:duplicate_column_name, :schema, nil, i+1)
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
      @csv_header
    end
    
    def fetch_error(error)
      e = error.message.match(/^([a-z ]+) (i|o)n line ([0-9]+)\.?$/i)
      message = e[1] rescue nil
      ERROR_MATCHERS.fetch(message, :unknown_error)
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
        next if col.blank?
        @formats[i] ||= []
        
        SIMPLE_FORMATS.each do |type, lambda|
          begin
            if lambda.call(col)
              @format = type
            end
          rescue ArgumentError, URI::InvalidURIError
          end
        end
        
        @formats[i] << @format
      end
    end
    
    def check_consistency
      percentages = []
                
      SIMPLE_FORMATS.keys.each do |type|
        @formats.each_with_index do |format,i|
          percentages[i] ||= {}
          unless format.nil?
            percentages[i][type] = format.count(type) / format.size.to_f
          end
        end
      end
            
      percentages.each_with_index do |col, i|
        next if col.values.blank?
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
      when Tempfile
        return ""
      else
        parsed = URI.parse(source)
        File.extname(parsed.path)
      end
    end
    
  end
end

module Csvlint

  class StreamingValidator

    include Csvlint::ErrorCollector

    attr_reader :encoding, :content_type, :extension, :headers, :line_breaks, :dialect, :csv_header, :schema, :data, :col_counts, :expected_columns
    ERROR_MATCHERS = {
      "Missing or stray quote" => :stray_quote,
      "Illegal quoting" => :whitespace,
      "Unclosed quoted field" => :unclosed_quote,
      "Unquoted fields do not allow \\r or \\n" => :line_breaks,
    }

    def initialize(stream, dialect = nil, schema = nil, limit_lines = nil, csv_options = nil)
      # suggested alternative initialisation parameters: stream, csv_options

      @stream = stream
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
      @limit_lines = limit_lines
      @csv_options = dialect_to_csv_options(@dialect)

      # This will get factored into Validate
      # @extension = parse_extension(@string) unless @string.nil?



      reset
      validate
      # TODO - separating the initialise and validate calls means that many of the specs that use Validator.valid to test that the object created
      # TODO - are no longer useful as they no longer contain the entire breadth of errors which this class can populate error collector with

    end

    def validate

      single_col = false
      # io = nil # This will get factored into Validate
      begin
        validate_metadata(@stream) # this shouldn't be called on every string
        parse_csv(@stream)
        sum = @col_counts.inject(:+)
        unless sum.nil?
          build_warnings(:title_row, :structure) if @col_counts.first < (sum / @col_counts.size.to_f)
        end
        # return expected_columns to calling class
        build_warnings(:check_options, :structure) if @expected_columns == 1
        check_consistency
      rescue OpenURI::HTTPError, Errno::ENOENT
        build_errors(:not_found)
      ensure
        # io.close if io && io.respond_to?(:close) # This will get factored into Validate, or a finishing state in this class
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

    # analyses the provided csv and builds errors, warnings and info messages
    def parse_csv(string)

      @expected_columns = 0
      current_line = 0
      reported_invalid_encoding = false
      all_errors = []
      @col_counts = []

      @csv_options[:encoding] = @encoding

      begin
        csv = CSV.new( string, @csv_options )
        @data = []
        @line_breaks = csv.row_sep
        if @line_breaks != "\r\n"
          build_info_messages(:nonrfc_line_breaks, :structure)
        end

        if string.class.eql?(String)
          build_errors(:line_breaks, :structure) and return if !string.match(csv.row_sep)
        end
        # terminating condition which is part of the streaming class no longer having responsibility for detecting row seperating chars
       begin
         row = csv.shift # row is an array from this point onwards
         @data << row
         if row
           if current_line == 1 && @csv_header
             # this conditional should be refactored somewhere
             row = row.reject{|col| col.nil? || col.empty?}
             validate_header(row)
             @col_counts << row.size
           else
             build_formats(row)
             @col_counts << row.reject{|col| col.nil? || col.empty?}.size
             @expected_columns = row.size unless @expected_columns != 0

             build_errors(:blank_rows, :structure, current_line, nil, string) if row.reject{ |c| c.nil? || c.empty? }.size == 0
             # Builds errors and warnings related to the provided schema file
             if @schema
               @schema.validate_row(row, current_line, all_errors)
               @errors += @schema.errors
               all_errors += @schema.errors
               @warnings += @schema.warnings
             else
               build_errors(:ragged_rows, :structure, current_line, nil, string) if !row.empty? && row.size != @expected_columns
             end
           end
         end
       rescue CSV::MalformedCSVError => e
         # within the validator this rescue is an edge case as it is assumed that the validation streamer will always be passed a class it can parse
         type = fetch_error(e) # refers to ERROR_MATCHER object
         build_errors(type, :structure, current_line, nil, string)
       end
        # the below rescue is no longer necessary with addition of line 114
      # rescue ArgumentError => ae
      #   build_errors(:invalid_encoding, :structure, current_line, nil, current_line) unless reported_invalid_encoding
      #   reported_invalid_encoding = true

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

    def fetch_error(error)
      e = error.message.match(/^(.+?)(?: [io]n)? \(?line \d+\)?\.?$/i)
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

    def build_formats(row)
      row.each_with_index do |col, i|
        next if col.nil? || col.empty?
        @formats[i] ||= Hash.new(0)

        format = if col.strip[FORMATS[:numeric]]
          :numeric
        elsif uri?(col)
          :uri
        elsif col[FORMATS[:date_db]] && date_format?(Date, col, '%Y-%m-%d')
          :date_db
        elsif col[FORMATS[:date_short]] && date_format?(Date, col, '%e %b')
          :date_short
        elsif col[FORMATS[:date_rfc822]] && date_format?(Date, col, '%e %b %Y')
          :date_rfc822
        elsif col[FORMATS[:date_long]] && date_format?(Date, col, '%B %e, %Y')
          :date_long
        elsif col[FORMATS[:dateTime_time]] && date_format?(Time, col, '%H:%M')
          :dateTime_time
        elsif col[FORMATS[:dateTime_hms]] && date_format?(Time, col, '%H:%M:%S')
          :dateTime_hms
        elsif col[FORMATS[:dateTime_db]] && date_format?(Time, col, '%Y-%m-%d %H:%M:%S')
          :dateTime_db
        elsif col[FORMATS[:dateTime_iso8601]] && date_format?(Time, col, '%Y-%m-%dT%H:%M:%SZ')
          :dateTime_iso8601
        elsif col[FORMATS[:dateTime_short]] && date_format?(Time, col, '%d %b %H:%M')
          :dateTime_short
        elsif col[FORMATS[:dateTime_long]] && date_format?(Time, col, '%B %d, %Y %H:%M')
          :dateTime_long
        else
          :string
        end

        @formats[i][format] += 1
      end
    end

    def check_consistency
      @formats.each_with_index do |format,i|
        if format
          total = format.values.reduce(:+).to_f
          if format.none?{|_,count| count / total >= 0.9}
            build_warnings(:inconsistent_values, :schema, nil, i + 1)
          end
        end
      end
    end

    private

    # def parse_extension(source)
    #
    #   case source
    #   when String
    #     return true
    #   when File
    #     return File.extname( source.path )
    #   when IO
    #     return ""
    #   when StringIO
    #     return ""
    #     when Tempfile
    #       # this is triggered when the revalidate dialect use case happens
    #     return ""
    #   else
    #     begin
    #       parsed = URI.parse(source)
    #       File.extname(parsed.path)
    #     rescue URI::InvalidURIError
    #       return ""
    #     end
    #   end
    # end

    def uri?(value)
      if value.strip[FORMATS[:uri]]
        uri = URI.parse(value)
        uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
      end
    rescue URI::InvalidURIError
      false
    end

    def date_format?(klass, value, format)
      klass.strptime(value, format).strftime(format) == value
    rescue ArgumentError # invalid date
      false
    end

    FORMATS = {
      :string => nil,
      :numeric => /\A[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?\z/,
      :uri => /\Ahttps?:/,
      :date_db => /\A\d{4,}-\d\d-\d\d\z/,                                               # "12345-01-01"
      :date_long => /\A(?:#{Date::MONTHNAMES.join('|')}) [ \d]\d, \d{4,}\z/,            # "January  1, 12345"
      :date_rfc822 => /\A[ \d]\d (?:#{Date::ABBR_MONTHNAMES.join('|')}) \d{4,}\z/,      # " 1 Jan 12345"
      :date_short => /\A[ \d]\d (?:#{Date::ABBR_MONTHNAMES.join('|')})\z/,              # "1 Jan"
      :dateTime_db => /\A\d{4,}-\d\d-\d\d \d\d:\d\d:\d\d\z/,                            # "12345-01-01 00:00:00"
      :dateTime_hms => /\A\d\d:\d\d:\d\d\z/,                                            # "00:00:00"
      :dateTime_iso8601 => /\A\d{4,}-\d\d-\d\dT\d\d:\d\d:\d\dZ\z/,                      # "12345-01-01T00:00:00Z"
      :dateTime_long => /\A(?:#{Date::MONTHNAMES.join('|')}) \d\d, \d{4,} \d\d:\d\d\z/, # "January 01, 12345 00:00"
      :dateTime_short => /\A\d\d (?:#{Date::ABBR_MONTHNAMES.join('|')}) \d\d:\d\d\z/,   # "01 Jan 00:00"
      :dateTime_time => /\A\d\d:\d\d\z/,                                                # "00:00"
    }.freeze
  end
end

module Csvlint

  class StreamingValidator

    include Csvlint::ErrorCollector

    attr_reader :encoding, :content_type, :extension, :headers, :line_breaks, :dialect, :csv_header, :schema, :data, :header_processed
    ERROR_MATCHERS = {
        "Missing or stray quote" => :stray_quote,
        "Illegal quoting" => :whitespace,
        "Unclosed quoted field" => :unclosed_quote,
        "Unquoted fields do not allow \\r or \\n" => :line_breaks,
    }

    def initialize(source = nil, dialect = nil, schema = nil, options = {}, row_sep = nil)
      # suggested alternative initialisation parameters: stream, csv_options

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
      @limit_lines = options[:limit_lines]
      @csv_options = dialect_to_csv_options(@dialect)

      @expected_columns = 0
      @col_counts = []

      @data = [] # it may be advisable to flush this on init?

      reset
      validate
      # TODO - separating the initialise and validate calls means that specs assertions in streaming_validator are more verbose, but can also be unit tested

    end

    def validate
      if @source.class == String
        validate_url
      else
        validate_stream
      end
    end

    def validate_stream
      i = 0
      @source.each_line do |line|
        validate_line(line, i)
        i = i+1
      end
    end

    def validate_url
      i = 0
      leading = ""
      request = Typhoeus::Request.new(@source)
      request.on_headers do |response|
        return build_errors(:not_found) if response.code == "404"
      end
      request.on_body do |chunk|
        io = StringIO.new(leading + chunk)
        io.each_line do |line|
          # Check if the last line is a line break - in which case it's a full line
          if line[-1, 1].include?("\n")
            validate_line(line, i)
            i = i+1
          else
            # If it's not a full line, then prepare to add it to the beginning of the next chunk
            leading = line
          end
        end
      end
      request.run
      # Validate the last line too
      validate_line(leading, i) unless leading == ""
    end

    def validate_line(input = nil, index = nil)
      single_col = false
      # TODO is single_col still required for single column CSV edge case, see spec it "should work correctly for single columns"
      @stream = input.present? ? input : @stream
      # reassign stream if validate has been invoked with an input, mostly a way of faking loosely coupled stuff while testing
      line = index.present? ? index : 0
      begin
        validate_metadata(@stream) if line <= 1 && !@header_processed # this should be a one shot, inelegant way of accomplishing
        report_line_breaks(line)
        parse_contents(@stream, line)
      rescue OpenURI::HTTPError, Errno::ENOENT # this rescue applies to the validate_metadata method
        build_errors(:not_found)
          # rescue CSV::MalformedCSVError => e
          # build_exception_message(e, @stream)
      ensure
        @stream.close if @stream && @stream.respond_to?(:close) #TODO This could get factored into Validate client, or a finishing state in this class
      end
      # finish - was once implicit, removed and specs revised to take account of this, only invoked when full spectrum of error reporting tested
    end

    def finish
      sum = @col_counts.inject(:+)
      unless sum.nil?
        build_warnings(:title_row, :structure) if @col_counts.first < (sum / @col_counts.size.to_f)
      end
      # return expected_columns to calling class
      build_warnings(:check_options, :structure) if @expected_columns == 1
      check_consistency
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
      @header_processed = true
      build_info_messages(:assumed_header, :structure) if assumed_header
    end

    def header?
      @csv_header
    end

    def report_line_breaks(line_no=nil)
      @line_breaks = CSV.new(@stream).row_sep
      if @line_breaks != "\r\n"
        build_info_messages(:nonrfc_line_breaks, :structure, line_no)
      end
    end

    def build_exception_messages(csvException, errChars, lineNo)
      #TODO 1 - this is a change in logic, rather than straight refactor of previous error building, however original logic is bonkers
      #TODO 2 - using .kind_of? is a very ugly fix here and it meant to work around instances where :auto symbol is preserved in @csv_options
      type = fetch_error(csvException)
      if !@csv_options[:row_sep].kind_of?(Symbol) && type == :unclosed_quote && !@stream.match(@csv_options[:row_sep])
        build_errors(:line_breaks, :structure)
      else
        build_errors(type, :structure, lineNo, nil, errChars)
      end
    end

    # analyses the provided csv and builds errors, warnings and info messages
    def parse_contents(stream, line = nil)
      # parse_contents will parse one line and apply headers, formats methods and error handle as appropriate

      current_line = line.present? ? line : 1
      reported_invalid_encoding = false
      all_errors = []

      @csv_options[:encoding] = @encoding

      begin
      row = CSV.parse_line(stream, @csv_options)
        # this is a one line substitute for CSV.new followed by row = CSV.shift. a CSV Row class is required
        # CSV.parse will return an array of arrays which breaks subsequent each_with_index invocations
        # TODO investigate if above would be a drag on memory

      rescue CSV::MalformedCSVError => e
        build_exception_messages(e, stream, current_line)
      end

      @data << row
      # TODO currently it doesn't matter where the above rescue is the @data array is either populated with nil or nothing
      # TODO is that intended behaviour?
      if row
        if current_line <= 1 && @csv_header
          # this conditional should be refactored somewhere
          row = row.reject { |col| col.nil? || col.empty? }
          validate_header(row)
          @col_counts << row.size
        else
          build_formats(row)
          @col_counts << row.reject { |col| col.nil? || col.empty? }.size
          @expected_columns = row.size unless @expected_columns != 0
          build_errors(:blank_rows, :structure, current_line, nil, stream.to_s) if row.reject { |c| c.nil? || c.empty? }.size == 0
          # Builds errors and warnings related to the provided schema file
          if @schema
            @schema.validate_row(row, current_line, all_errors)
            @errors += @schema.errors
            all_errors += @schema.errors
            @warnings += @schema.warnings
          else
            build_errors(:ragged_rows, :structure, current_line, nil, stream.to_s) if !row.empty? && row.size != @expected_columns
          end
        end
      end
      # TODO the below argumenterror is an artefact of when everything was in one long method
      # TODO however this is an important rescue to content parsing as the README stipulates it catches
      # TODO "encoding error when parsing row, e.g. because of invalid characters"
      # rescue ArgumentError => ae
      #   build_errors(:invalid_encoding, :structure, current_line, nil, current_line) unless reported_invalid_encoding
      #   reported_invalid_encoding = true
      # end
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

        format =
            if col.strip[FORMATS[:numeric]]
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

    def parse_extension(source)

      case source
        when String
          return true
        when File
          return File.extname( source.path )
        when IO
          return ""
        when StringIO
          return ""
        when Tempfile
          # this is triggered when the revalidate dialect use case happens
          return ""
        else
          begin
            parsed = URI.parse(source)
            File.extname(parsed.path)
          rescue URI::InvalidURIError
            return ""
          end
      end
    end

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

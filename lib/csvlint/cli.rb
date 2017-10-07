require 'csvlint'
require 'colorize'
require 'json'
require 'pp'
require 'thor'

require 'active_support/inflector'

module Csvlint
  class Cli < Thor

    desc "myfile.csv OR csvlint http://example.com/myfile.csv", "Supports validating CSV files to check their syntax and contents"

    option :dump_errors, desc: "Pretty print error and warning objects.", type: :boolean, aliases: :d
    option :schema, banner: "FILENAME OR URL", desc: "Schema file", aliases: :s
    option :json, desc: "Output errors as JSON", type: :boolean, aliases: :j
    option :werror, desc: "Make all warnings into errors", type: :boolean, aliases: :w

    def validate(source = nil)
      source = read_source(source)
      @schema = get_schema(options[:schema]) if options[:schema]
      fetch_schema_tables(@schema, options) if source.nil?

      valid = validate_csv(source, @schema, options[:dump_errors], options[:json], options[:werror])
      exit 1 unless valid
    end

    def help
      self.class.command_help(shell, :validate)
    end

    default_task :validate

    private

      def read_source(source)
        if source.nil?
          # If no source is present, try reading from stdin
          if !$stdin.tty?
            source = StringIO.new(STDIN.read) rescue nil
            return_error "No CSV data to validate" if !options[:schema] && source.nil?
          end
        else
          # If the source isn't a URL, it's a file
          unless source =~ /^http(s)?/
            begin
              source = File.new( source )
            rescue Errno::ENOENT
              return_error "#{source} not found"
            end
          end
        end

        source
      end

      def get_schema(schema)
        begin
          schema = Csvlint::Schema.load_from_json(schema, false)
        rescue Csvlint::Csvw::MetadataError => e
          return_error "invalid metadata: #{e.message}#{" at " + e.path if e.path}"
        rescue OpenURI::HTTPError, Errno::ENOENT
          return_error "#{options[:schema]} not found"
        end

        if schema.class == Csvlint::Schema && schema.description == "malformed"
          return_error "invalid metadata: malformed JSON"
        end

        schema
      end

      def fetch_schema_tables(schema, options)
        valid = true

        unless schema.instance_of? Csvlint::Csvw::TableGroup
          return_error "No CSV data to validate."
        end
        schema.tables.keys.each do |source|
          begin
            source = source.sub("file:","")
            source = File.new( source )
          rescue Errno::ENOENT
            return_error "#{source} not found"
          end unless source =~ /^http(s)?/
          valid &= validate_csv(source, schema, options[:dump_errors], nil, options[:werror])
        end

        exit 1 unless valid
      end

      def print_error(index, error, dump, color)
        location = ""
        location += error.row.to_s if error.row
        location += "#{error.row ? "," : ""}#{error.column.to_s}" if error.column
        if error.row || error.column
          location = "#{error.row ? "Row" : "Column"}: #{location}"
        end
        output_string = "#{index+1}. "
        if error.column && @schema && @schema.class == Csvlint::Schema
          if @schema.fields[error.column - 1] != nil
            output_string += "#{@schema.fields[error.column - 1].name}: "
          end
        end
        output_string += "#{error.type}"
        output_string += ". #{location}" unless location.empty?
        output_string += ". #{error.content}" if error.content

        if $stdout.tty?
          puts output_string.colorize(color)
        else
          puts output_string
        end

        if dump
          pp error
        end
      end

      def print_errors(errors, dump)
        if errors.size > 0
          errors.each_with_index { |error, i| print_error(i, error, dump, :red)  }
        end
      end

      def return_error(message)
        if $stdout.tty?
          puts message.colorize(:red)
        else
          puts message
        end
        exit 1
      end

      def validate_csv(source, schema, dump, json, werror)
        @error_count = 0

        if json === true
          validator = Csvlint::Validator.new( source, {}, schema )
        else
          validator = Csvlint::Validator.new( source, {}, schema, { lambda: report_lines } )
        end

        if source.class == String
          csv = source
        elsif source.class == File
          csv = source.path
        else
          csv = "CSV"
        end

        if json === true
          json = {
            validation: {
              state: validator.valid? ? "valid" : "invalid",
              errors: validator.errors.map { |v| hashify(v) },
              warnings: validator.warnings.map { |v| hashify(v) },
              info: validator.info_messages.map { |v| hashify(v) },
            }
          }.to_json
          print json
        else
          if $stdout.tty?
            puts "\r\n#{csv} is #{validator.valid? ? "VALID".green : "INVALID".red}"
          else
            puts "\r\n#{csv} is #{validator.valid? ? "VALID" : "INVALID"}"
          end
          print_errors(validator.errors,   dump)
          print_errors(validator.warnings, dump)
        end
        
        return false if werror && validator.warnings.size > 0
        return validator.valid?
      end

      def hashify(error)
        h = {
          type: error.type,
          category: error.category,
          row: error.row,
          col: error.column
        }

        if error.column && @schema && @schema.class == Csvlint::Schema && @schema.fields[error.column - 1] != nil
          field = @schema.fields[error.column - 1]
          h[:header] = field.name
          h[:constraints] = Hash[field.constraints.map {|k,v| [k.underscore, v] }]
        end

        h
      end

      def report_lines
        lambda do |row|
          new_errors = row.errors.count
          if new_errors > @error_count
            print "!".red
          else
            print ".".green
          end
          @error_count = new_errors
        end
      end

  end
end

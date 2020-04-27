module Csvlint

  class Field
    include Csvlint::ErrorCollector

    attr_reader :name, :constraints, :title, :description

    def initialize(name, constraints={}, title=nil, description=nil)
      @name = name
      @constraints = constraints || {}
      @uniques = Set.new
      @title = title
      @description = description
      reset
    end

    def validate_column(value, row=nil, column=nil, all_errors=[])
      reset
      unless all_errors.any?{|error| ((error.type == :invalid_regex) && (error.column == column))}
        validate_regex(value, row, column, all_errors)
      end
      validate_length(value, row, column)
      validate_values(value, row, column)
      parsed = validate_type(value, row, column)
      validate_range(parsed, row, column) if parsed != nil
      return valid?
    end

    private
      def validate_length(value, row, column)
        if constraints["required"] == true
          build_errors(:missing_value, :schema, row, column, value,
            { "required" => true }) if value.nil? || value.length == 0
        end
        if constraints["minLength"]
          build_errors(:min_length, :schema, row, column, value,
            { "minLength" => constraints["minLength"] }) if value.nil? || value.length < constraints["minLength"]
        end
        if constraints["maxLength"]
            build_errors(:max_length, :schema, row, column, value,
             { "maxLength" => constraints["maxLength"] } ) if !value.nil? && value.length > constraints["maxLength"]
        end
      end

      def validate_regex(value, row, column, all_errors)
        pattern = constraints["pattern"]
        if pattern
          begin
            Regexp.new(pattern)
            build_errors(:pattern, :schema, row, column, value,
            { "pattern" => constraints["pattern"] } ) unless value.match( constraints["pattern"] )
          rescue RegexpError
            build_regex_error(value, row, column, pattern, all_errors)
          end
        end
      end

      def build_regex_error(value, row, column, pattern, all_errors)
        return if @regex_error_exists
        build_errors(:invalid_regex, :schema, nil, column, ("#{name}: Constraints: Pattern: #{pattern}"),
          { "pattern" => constraints["pattern"] })
        @regex_error_exists = true
      end

      def validate_values(value, row, column)
        return if constraints["required"] == true && (value.nil? || value.length == 0)

        # If a pattern exists, raise an invalid regex error if it is not in
        # valid regex form, else, if the value of the relevant field in the csv
        # does not match the given regex pattern in the schema, raise a
        # pattern error.
        if constraints["unique"] == true
          if @uniques.include? value
            build_errors(:unique, :schema, row, column, value, { "unique" => true })
          else
            @uniques << value
          end
        end
      end

      def validate_type(value, row, column)
        if constraints["type"] && value != ""
          parsed = convert_to_type(value)
          if parsed == nil
            failed = { "type" => constraints["type"] }
            failed["datePattern"] = constraints["datePattern"] if constraints["datePattern"]
            build_errors(:invalid_type, :schema, row, column, value, failed)
            return nil
          end
          return parsed
        end
        return nil
      end

      def validate_range(value, row, column)
        #TODO: we're ignoring issues with converting ranges to actual types, maybe we
        #should generate a warning? The schema is invalid
        if constraints["minimum"]
          minimumValue = convert_to_type( constraints["minimum"] )
          if minimumValue
            build_errors(:below_minimum, :schema, row, column, value,
              { "minimum" => constraints["minimum"] }) unless value >= minimumValue
          end
        end
        if constraints["maximum"]
          maximumValue = convert_to_type( constraints["maximum"] )
          if maximumValue
            build_errors(:above_maximum, :schema, row, column, value,
            { "maximum" => constraints["maximum"] }) unless value <= maximumValue
          end
        end
      end

      def convert_to_type(value)
        parsed = nil
        tv = TYPE_VALIDATIONS[constraints["type"]]
        if tv
          begin
            parsed = tv.call value, constraints
          rescue ArgumentError
          end
        end
        return parsed
      end

      TYPE_VALIDATIONS = {
          'http://www.w3.org/2001/XMLSchema#string'  => lambda { |value, constraints| value },
          'http://www.w3.org/2001/XMLSchema#int'     => lambda { |value, constraints| Integer value },
          'http://www.w3.org/2001/XMLSchema#integer' => lambda { |value, constraints| Integer value },
          'http://www.w3.org/2001/XMLSchema#float'   => lambda { |value, constraints| Float value },
          'http://www.w3.org/2001/XMLSchema#double'   => lambda { |value, constraints| Float value },
          'http://www.w3.org/2001/XMLSchema#anyURI'  => lambda do |value, constraints|
            begin
              u = URI.parse value
              raise ArgumentError unless u.kind_of?(URI::HTTP) || u.kind_of?(URI::HTTPS)
            rescue URI::InvalidURIError
              raise ArgumentError
            end
            u
          end,
          'http://www.w3.org/2001/XMLSchema#boolean' => lambda do |value, constraints|
            return true if ['true', '1'].include? value
            return false if ['false', '0'].include? value
            raise ArgumentError
          end,
          'http://www.w3.org/2001/XMLSchema#nonPositiveInteger' => lambda do |value, constraints|
            i = Integer value
            raise ArgumentError unless i <= 0
            i
          end,
          'http://www.w3.org/2001/XMLSchema#negativeInteger' => lambda do |value, constraints|
            i = Integer value
            raise ArgumentError unless i < 0
            i
          end,
          'http://www.w3.org/2001/XMLSchema#nonNegativeInteger' => lambda do |value, constraints|
            i = Integer value
            raise ArgumentError unless i >= 0
            i
          end,
          'http://www.w3.org/2001/XMLSchema#positiveInteger' => lambda do |value, constraints|
            i = Integer value
            raise ArgumentError unless i > 0
            i
          end,
          'http://www.w3.org/2001/XMLSchema#dateTime' => lambda do |value, constraints|
            date_pattern = constraints["datePattern"] || "%Y-%m-%dT%H:%M:%SZ"
            d = DateTime.strptime(value, date_pattern)
            raise ArgumentError unless d.strftime(date_pattern) == value
            d
          end,
          'http://www.w3.org/2001/XMLSchema#date' => lambda do |value, constraints|
            date_pattern = constraints["datePattern"] || "%Y-%m-%d"
            d = Date.strptime(value, date_pattern)
            raise ArgumentError unless d.strftime(date_pattern) == value
            d
          end,
          'http://www.w3.org/2001/XMLSchema#time' => lambda do |value, constraints|
            date_pattern = constraints["datePattern"] || "%H:%M:%S"
            d = DateTime.strptime(value, date_pattern)
            raise ArgumentError unless d.strftime(date_pattern) == value
            d
          end,
          'http://www.w3.org/2001/XMLSchema#gYear' => lambda do |value, constraints|
            date_pattern = constraints["datePattern"] || "%Y"
            d = Date.strptime(value, date_pattern)
            raise ArgumentError unless d.strftime(date_pattern) == value
            d
          end,
          'http://www.w3.org/2001/XMLSchema#gYearMonth' => lambda do |value, constraints|
            date_pattern = constraints["datePattern"] || "%Y-%m"
            d = Date.strptime(value, date_pattern)
            raise ArgumentError unless d.strftime(date_pattern) == value
            d
          end,
      }
  end
end

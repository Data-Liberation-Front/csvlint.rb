module Csvlint
  
  class Field
    include Csvlint::ErrorCollector
    include Csvlint::Types

    attr_reader :name, :constraints, :title, :description
      
    def initialize(name, constraints={}, title=nil, description=nil)
      @name = name
      @constraints = constraints || {}
      @uniques = Set.new
      @title = title
      @description = description
      reset
    end
    
    def validate_column(value, row=nil, column=nil)
      reset
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
      
      def validate_values(value, row, column)
        if constraints["pattern"]
          build_errors(:pattern, :schema, row, column, value, 
           { "pattern" => constraints["pattern"] } ) if !value.nil? && !value.match( constraints["pattern"] )
        end
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
  end
end
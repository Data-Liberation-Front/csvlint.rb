require 'set'

module Csvlint
  
  class Field
    include Csvlint::ErrorCollector

    attr_reader :name, :constraints
    
    def initialize(name, constraints={})
      @name = name
      @constraints = constraints || {}
      @uniques = Set.new
      reset
    end
    
    def validate_column(value, row=nil, column=nil)
      reset
      if constraints["required"] == true
        build_errors(:missing_value, :schema, row, column) if value.nil? || value.length == 0
      end
      if constraints["minLength"]
        build_errors(:min_length, :schema, row, column) if value.nil? || value.length < constraints["minLength"]
      end
      if constraints["maxLength"]
          build_errors(:max_length, :schema, row, column) if !value.nil? && value.length > constraints["maxLength"]
      end
      if constraints["pattern"]
          build_errors(:pattern, :schema, row, column) if !value.nil? && !value.match( constraints["pattern"] )
      end
      if constraints["unique"] == true
        if @uniques.include? value
          build_errors(:unique, :schema, row, column)
        else
          @uniques << value
        end
      end
      if constraints["type"] == "http://www.w3.org/2001/XMLSchema#int"
        begin
          Integer value
        rescue ArgumentError => e
          build_errors(:invalid_type, :schema, row, column)
        end
      end

      return valid?
    end

  end
end
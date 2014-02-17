module Csvlint
  
  class Field
    include Csvlint::ErrorCollector

    attr_reader :name, :constraints
    
    def initialize(name, constraints={})
      @name = name
      @constraints = constraints || {}
      reset
    end
    
    def validate_column(value, row=nil, column=nil)
      reset
      if constraints["required"] == true
        build_errors(:missing_value, :schema, row, column) if value.nil? || value.length == 0
      end
      if constraints["minLength"]
        build_errors(:minLength, :schema, row, column) if value.nil? || value.length < constraints["minLength"]
      end
      if constraints["maxLength"]
          build_errors(:maxLength, :schema, row, column) if !value.nil? && value.length > constraints["maxLength"]
      end
      if constraints["pattern"]
          build_errors(:pattern, :schema, row, column) if !value.nil? && !value.match( constraints["pattern"] )
      end
      return valid?
    end    
    
  end
end
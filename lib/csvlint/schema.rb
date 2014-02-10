module Csvlint
  
  class Schema
    
    include Csvlint::ErrorCollector
    
    attr_reader :uri, :fields
    
    def initialize(uri, fields=[])
      @uri = uri
      @fields = fields
      reset
    end
    
    def validate_row(values, row=nil)
      reset
      values.each_with_index do |value,i|
        if fields[i]
          field = fields[i]
          field.validate_column(value, row, i)
          @errors += fields[i].errors
          @warnings += fields[i].warnings        
        end
      end
      return valid?
    end
    
  end
end
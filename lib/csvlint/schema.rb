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
          result = field.validate_column(value, row, i)
          @errors += fields[i].errors
          @warnings += fields[i].warnings        
        end
      end
      return valid?
    end
    
    def Schema.from_json_table(uri, json)
      fields = []
      json["fields"].each do |field_desc|
        fields << Csvlint::Field.new( field_desc["name"] ,field_desc["constraints"] || [])
      end
      return Schema.new( uri , fields )
    end
    
    def Schema.load_from_json_table(uri)
      begin
        json = JSON.parse( open(uri).read )
        return Schema.from_json_table(uri,json)
      rescue
        return nil
      end
    end
    
  end
end
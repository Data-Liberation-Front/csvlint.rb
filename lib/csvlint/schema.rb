require "set"

module Csvlint
  
  class Schema
    
    include Csvlint::ErrorCollector
    
    attr_reader :uri, :fields
    
    def initialize(uri, fields=[])
      @uri = uri
      @fields = fields
      reset
    end

    def validate_header(header)
      names = Set.new
      header.each_with_index do |name,i|
        build_warnings(:header_name, :schema, nil, i+1) if fields[i].name.downcase != name.downcase
        build_errors(:empty_column_name, :schema, nil, i+1) if name == ""
        if names.include?(name)
          build_errors(:duplicate_column_name, :schema, nil, i+1)
        else
          names << name
        end
      end
      return valid?
    end
        
    def validate_row(values, row=nil)
      reset
      if values.length < fields.length
        fields[values.size..-1].each_with_index do |field, i|
          build_warnings(:missing_column, :schema, row, values.size+i+1)
        end
      end
      if values.length > fields.length
        values[fields.size..-1].each_with_index do |data_column, i|
          build_warnings(:extra_column, :schema, row, fields.size+i+1)
        end
      end
      
      fields.each_with_index do |field,i|
        value = values[i] || ""
        result = field.validate_column(value, row, i)
        @errors += fields[i].errors
        @warnings += fields[i].warnings        
      end
            
      return valid?
    end
    
    def Schema.from_json_table(uri, json)
      fields = []
      json["fields"].each do |field_desc|
        fields << Csvlint::Field.new( field_desc["name"] , field_desc["constraints"] )
      end if json["fields"]
        
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
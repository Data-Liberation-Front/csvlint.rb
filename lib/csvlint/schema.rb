module Csvlint
  
  class Schema
    
    include Csvlint::ErrorCollector
    
    attr_reader :uri, :fields, :title, :description
    
    def initialize(uri, fields=[], title=nil, description=nil)
      @uri = uri
      @fields = fields
      @title = title
      @description = description
      reset
    end

    def validate_header(header)
      reset

      found_header = header.to_csv(:row_sep => '')
      expected_header = @fields.map{ |f| f.name }.to_csv(:row_sep => '')
      if found_header != expected_header
        build_warnings(:malformed_header, :schema, 1, nil, found_header, expected_header)
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
        result = field.validate_column(value, row, i+1)
        @errors += fields[i].errors
        @warnings += fields[i].warnings        
      end
            
      return valid?
    end
    
    def Schema.from_json_table(uri, json)
      fields = []
      json["fields"].each do |field_desc|
        fields << Csvlint::Field.new( field_desc["name"] , field_desc["constraints"], 
          field_desc["title"], field_desc["description"] )
      end if json["fields"]
      return Schema.new( uri , fields, json["title"], json["description"] )
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
module Csvlint

  class Schema

    include Csvlint::ErrorCollector

    attr_reader :type, :uri, :fields, :title, :description

    def initialize(uri, fields=[], title=nil, description=nil, type: :json_table)
      @type = type
      @uri = uri
      @fields = fields
      @title = title
      @description = description
      reset
    end

    def validate_header(header)
      reset

      if @type == :csvw
        header.each_with_index do |found,i|
          if @fields && @fields[i]
            if @fields[i].title
              expected_titles = @fields[i].title
              build_warnings(:malformed_header, :schema, 1, nil, found, "expectedHeader" => expected_titles.join("|")) unless expected_titles.include? found
            else
              expected_title = @fields[i].name
              build_warnings(:malformed_header, :schema, 1, nil, found, "expectedHeader" => expected_title) unless found == expected_title
            end
          end
        end
      else
        found_header = header.to_csv(:row_sep => '')
        expected_header = @fields.map{ |f| f.name }.to_csv(:row_sep => '')
        if found_header != expected_header
          build_warnings(:malformed_header, :schema, 1, nil, found_header, "expectedHeader" => expected_header)
        end
      end
      return valid?
    end

    def validate_row(values, row=nil, all_errors=[])
      reset
      if values.length < fields.length
        fields[values.size..-1].each_with_index do |field, i|
          build_warnings(:missing_column, :schema, row, values.size+i+1)
        end
      end
      unless @type == :csvw && fields.empty?
        if values.length > fields.length
          values[fields.size..-1].each_with_index do |data_column, i|
            build_warnings(:extra_column, :schema, row, fields.size+i+1)
          end
        end
      end

      fields.each_with_index do |field,i|
        value = values[i] || ""
        result = field.validate_column(value, row, i+1, all_errors)
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

    def Schema.from_csvw_metadata(uri, json)
      fields = []
      json["tableSchema"]["columns"].each do |field_desc|
        constraints = {}
        constraints["required"] = field_desc["required"]
        constraints["minLength"] = field_desc["datatype"]["minLength"] if field_desc["datatype"]
        if field_desc["datatype"]
          if field_desc["datatype"]["base"] == "date"
            constraints["datePattern"] = field_desc["datatype"]["format"]
          else
            constraints["pattern"] = field_desc["datatype"]["format"]
          end
        end
        fields << Csvlint::Field.new( field_desc["name"] , constraints , Array(field_desc["titles"]) )
      end if json["tableSchema"]
      return Schema.new(uri, fields, type: :csvw)
    end

    def Schema.load_from_json(uri)
      begin
        json = JSON.parse( open(uri).read )
        if json["@context"]
          return Schema.from_csvw_metadata(uri,json)
        else
          return Schema.from_json_table(uri,json)
        end
      rescue
        return Schema.new(nil, [], "malformed", "malformed")
      end
    end

  end
end

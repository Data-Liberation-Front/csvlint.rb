module Csvlint

  class Schema

    include Csvlint::ErrorCollector

    attr_reader :uri, :fields, :fields_by_index, :title, :description

    def initialize(uri, fields=[], title=nil, description=nil)
      @uri = uri
      @fields = fields
      @title = title
      @description = description
      reset
    end

    def validate_header(header)
      reset
      @fields_by_index = {}
      header.each_with_index do |name,i|
        field = fields.find { |field| field.name == name }
        if field
          fields_by_index[i] = field
          build_warnings(:different_index_header, :schema, nil, i+1, name) if fields[i].try(:name) != name
        else
          build_warnings(:extra_header, :schema, nil, i+1, name)
        end
      end

      (fields - fields_by_index.values).each do |field|
        build_warnings(:missing_header, :schema, nil, fields.index(field)+1, field.name)
      end

      return valid?
    end

    def validate_row(values, row=nil)
      reset

      values.each_with_index do |value,i|
        field = fields_by_index[i]
        if field
          result = field.validate_column(value || "", row, fields.index(field)+1)
          @errors += field.errors
          @warnings += field.warnings
        else
          build_warnings(:extra_column, :schema, row, i)
        end
      end

      (fields - fields_by_index.values).each_with_index do |field,i|
        build_warnings(:missing_column, :schema, row, fields.index(field)+1, field.name)
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

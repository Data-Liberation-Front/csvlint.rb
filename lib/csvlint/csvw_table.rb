module Csvlint

  class CsvwTable

    include Csvlint::ErrorCollector

    attr_reader :columns, :table_direction, :foreign_keys, :id, :notes, :primary_key, :schema, :suppress_output, :transformations, :url, :annotations

    def initialize(url, columns: [], table_direction: :auto, foreign_keys: [], id: nil, notes: [], primary_key: nil, schema: nil, suppress_output: false, transformations: [], annotations: [], warnings: [])
      @url = url
      @columns = columns
      @table_direction = table_direction
      @foreign_keys = foreign_keys
      @id = id
      @notes = notes
      @primary_key = primary_key
      @schema = schema
      @suppress_output = suppress_output
      @transformations = transformations
      @annotations = annotations
      reset
      @warnings += warnings
      @errors += columns.map{|c| c.errors}.flatten
      @warnings += columns.map{|c| c.warnings}.flatten
    end

    def validate_header(headers)
      reset
      headers.each_with_index do |header,i|
        if columns[i]
          columns[i].validate_header(header)
          @errors += columns[i].errors
          @warnings += columns[i].warnings
        else
          build_errors(:malformed_header, :schema, 1, nil, header, nil)
        end
      end unless columns.empty?
      return valid?
    end

    def validate_row(values, row=nil)
      reset
      values.each_with_index do |value,i|
        column = columns[i]
        column.validate(value, row)
        @errors += column.errors
        @warnings += column.warnings
      end unless columns.empty?
      return valid?
    end

    def CsvwTable.from_json(table_desc, base_url=nil, lang="und", inherited_properties={})
      annotations = {}
      warnings = []
      table_properties = {}
      columns = []

      table_desc.each do |property,value|
        unless VALID_PROPERTIES.include? property
          v, warning, type = CsvwPropertyChecker.check_property(property, value, base_url, lang)
          if warning.nil? || warning.empty?
            if type == :annotation
              annotations[property] = v
            elsif type == :table
              table_properties[property] = v
            elsif type == :column
              warnings << Csvlint::ErrorMessage.new(:invalid_property, :metadata, nil, nil, "#{property}", nil)
            else
              inherited_properties[property] = v
            end
          else
            warnings += Array(warning).map{ |w| Csvlint::ErrorMessage.new(w, :metadata, nil, nil, "#{property}: #{value}", nil) }
          end
        end
      end

      url = URI.join(base_url, table_desc["url"])

      id = table_desc["@id"]
      raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_desc["url"]}')].@id"), "@id starts with _:" if id =~ /^_:/
      raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_desc["url"]}')].@type"), "@type of table is not 'Table'" if table_desc["@type"] && table_desc["@type"] != 'Table'

      table_schema = table_properties["tableSchema"] || inherited_properties["tableSchema"]
      column_names = []
      foreign_keys = []
      primary_key = nil
      if table_schema
        raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_desc["url"]}')].tableSchema.columns"), "schema columns is not an array" unless table_schema["columns"].instance_of? Array
        table_schema["columns"].each_with_index do |column_desc,i|
          if column_desc.instance_of? Hash
            column = Csvlint::CsvwColumn.from_json(i+1, column_desc, base_url, lang, inherited_properties)
            column_names << column.name unless column.name.nil?
            columns << column
          else
            warnings << Csvlint::ErrorMessage.new(:invalid_column_description, :metadata, nil, nil, "#{column_desc}", nil)
          end
        end

        primary_key = table_schema["primaryKey"]
        primary_key.each do |reference|
          unless column_names.include? reference
            warnings << Csvlint::ErrorMessage.new(:invalid_column_reference, :metadata, nil, nil, "primaryKey: #{reference}", nil)
            table_schema.except!("primaryKey")
          end
        end if primary_key

        foreign_keys = table_schema["foreignKeys"]
        foreign_keys.each_with_index do |foreign_key, i|
          foreign_key["columnReference"].each do |reference|
            raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_desc["url"]}')].tableSchema.foreignKeys[#{i}].columnReference"), "foreignKey references non-existant column" unless column_names.include? reference
          end
        end if foreign_keys

      end


      return CsvwTable.new(url, id: id, columns: columns, foreign_keys: foreign_keys, primary_key: primary_key, annotations: annotations, warnings: warnings)
    end

    private
      VALID_PROPERTIES = [ 'url' ]

  end
end

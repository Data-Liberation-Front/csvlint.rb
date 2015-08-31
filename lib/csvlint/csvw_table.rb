module Csvlint

  class CsvwTable

    include Csvlint::ErrorCollector

    attr_reader :columns, :dialect, :table_direction, :foreign_keys, :id, :notes, :primary_key, :schema, :suppress_output, :transformations, :url, :annotations

    def initialize(url, columns: [], dialect: {}, table_direction: :auto, foreign_keys: [], id: nil, notes: [], primary_key: nil, schema: nil, suppress_output: false, transformations: [], annotations: [], warnings: [])
      @url = url
      @columns = columns
      @dialect = dialect
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
      notes = []
      inherited_properties = inherited_properties.clone

      table_desc.each do |property,value|
        if property =="@type"
          raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_desc["url"]}')].@type"), "@type of table is not 'Table'" unless value == 'Table'
        elsif property == "notes"
          notes = value
        else
          v, warning, type = CsvwPropertyChecker.check_property(property, value, base_url, lang)
          warnings += Array(warning).map{ |w| Csvlint::ErrorMessage.new(w, :metadata, nil, nil, "#{property}: #{value}", nil) } unless warning.nil? || warning.empty?
          if type == :annotation
            annotations[property] = v
          elsif type == :table || type == :common
            table_properties[property] = v
          elsif type == :column
            warnings << Csvlint::ErrorMessage.new(:invalid_property, :metadata, nil, nil, "#{property}", nil)
          else
            inherited_properties[property] = v
          end
        end
      end

      table_schema = table_properties["tableSchema"] || inherited_properties["tableSchema"]
      column_names = []
      foreign_keys = []
      primary_key = nil
      if table_schema
        raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_desc["url"]}')].tableSchema.columns"), "schema columns is not an array" unless table_schema["columns"].instance_of? Array
        virtual_columns = false
        table_schema["columns"].each_with_index do |column_desc,i|
          if column_desc.instance_of? Hash
            column = Csvlint::CsvwColumn.from_json(i+1, column_desc, base_url, lang, inherited_properties)
            raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_desc["url"]}')].tableSchema.columns[#{i}].virtual"), "virtual columns before non-virtual column #{column.name || i}" if virtual_columns && !column.virtual
            virtual_columns = virtual_columns || column.virtual
            raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_desc["url"]}')].tableSchema.columns"), "multiple columns named #{column.name}" if column_names.include? column.name
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

      return CsvwTable.new(table_properties["url"], 
        id: table_properties["@id"], 
        columns: columns, 
        dialect: table_properties["dialect"],
        foreign_keys: foreign_keys, 
        notes: notes, 
        primary_key: primary_key, 
        annotations: annotations, 
        warnings: warnings
      )
    end

  end
end

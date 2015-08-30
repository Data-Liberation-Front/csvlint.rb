module Csvlint

  class CsvwTable

    include Csvlint::ErrorCollector

    attr_reader :columns, :table_direction, :foreign_keys, :id, :notes, :schema, :suppress_output, :transformations, :url, :annotations

    def initialize(url, columns: [], table_direction: :auto, foreign_keys: [], id: nil, notes: [], schema: nil, suppress_output: false, transformations: [], annotations: [], warnings: [])
      @url = url
      @columns = columns
      @table_direction = table_direction
      @foreign_keys = foreign_keys
      @id = id
      @notes = notes
      @schema = schema
      @suppress_output = suppress_output
      @transformations = transformations
      @annotations = annotations
      reset
      @warnings += warnings
      @errors += columns.map{|c| c.errors}.flatten
      @warnings += columns.map{|c| c.warnings}.flatten
    end

    def validate_header(header)
      reset
      return true
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
      columns = []
      table_schema = table_properties["tableSchema"] || inherited_properties["tableSchema"]
      if table_schema
        table_schema["columns"].each_with_index do |column_desc,i|
          column = Csvlint::CsvwColumn.from_json(i+1, column_desc, base_url, lang, inherited_properties)
          columns << column
        end
      end
      return CsvwTable.new(URI.join(base_url, table_desc["url"]), columns: columns, annotations: annotations, warnings: warnings)
    end

    private
      VALID_PROPERTIES = [ 'url' ]

  end
end

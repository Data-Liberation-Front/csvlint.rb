module Csvlint

  class CsvwTable

    include Csvlint::ErrorCollector

    attr_reader :columns, :table_direction, :foreign_keys, :id, :notes, :schema, :suppress_output, :transformations, :url, :annotations

    def initialize(url, columns: [], table_direction: :auto, foreign_keys: [], id: nil, notes: [], schema: nil, suppress_output: false, transformations: [], annotations: [])
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
      @errors += columns.map{|c| c.errors}.flatten
      @warnings += columns.map{|c| c.warnings}.flatten
    end

    def validate_header(header)
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

    def CsvwTable.from_json(url, table_desc, table_group_desc={})
      columns = []
      if table_desc["tableSchema"]
        table_desc["tableSchema"]["columns"].each_with_index do |column_desc,i|
          column = Csvlint::CsvwColumn.from_json(i+1, column_desc)
          columns << column
        end
      end
      return CsvwTable.new(URI.join(url, table_desc["url"]), columns: columns)
    end

    private
      VALID_PROPERTIES = []

  end
end

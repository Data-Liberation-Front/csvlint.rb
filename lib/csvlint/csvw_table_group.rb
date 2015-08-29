module Csvlint

  class CsvwTableGroup

    include Csvlint::ErrorCollector

    attr_reader :url, :id, :tables, :notes, :annotations

    def initialize(url, id: nil, tables: {}, notes: [], annotations: {})
      @url = url
      @id = id
      @tables = tables
      @notes = notes
      @annotations = annotations
      reset
      @errors += @tables.map{|url,table| table.errors}.flatten
      @warnings += @tables.map{|url,table| table.warnings}.flatten
    end

    def validate_header(header, table_url)
      reset
      table_url = "file:#{File.absolute_path(table_url)}" if table_url.instance_of? File
      table = tables[table_url]
      table.validate_header(header)
      @errors += table.errors
      @warnings += table.warnings
      return valid?
    end

    def validate_row(values, row=nil, all_errors=[], table_url)
      reset
      table_url = "file:#{File.absolute_path(table_url)}" if table_url.instance_of? File
      table = tables[table_url]
      table.validate_row(values, row)
      @errors += table.errors
      @warnings += table.warnings
      return valid?
    end

    def CsvwTableGroup.from_json(url, json)
      tables = {}
      annotations = []
      if json["url"]
        table_url = URI.join(url, json["url"]).to_s
        tables[table_url] = Csvlint::CsvwTable.from_json(url, json, { "tables" => [ json ] })
      else
        json["tables"].each do |table_desc|
          table_url = URI.join(url, table_desc["url"]).to_s
          table = Csvlint::CsvwTable.from_json(url, table_desc, json)
          tables[table_url] = table
        end
      end
      return CsvwTableGroup.new(url, id: json["@id"], tables: tables, notes: json["notes"] || [], annotations: annotations)
    end

    private
      VALID_PROPERTIES = ['tables', 'transformations', 'tableDirection', 'tableSchema', 'dialect', 'notes', '@context', '@id', '@type']

  end
end

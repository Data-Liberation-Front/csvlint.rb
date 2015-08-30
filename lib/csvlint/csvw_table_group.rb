module Csvlint

  class CsvwTableGroup

    include Csvlint::ErrorCollector

    attr_reader :url, :id, :tables, :notes, :annotations

    def initialize(url, id: nil, tables: {}, notes: [], annotations: {}, warnings: [])
      @url = url
      @id = id
      @tables = tables
      @notes = notes
      @annotations = annotations
      reset
      @warnings += warnings
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
      base_url = url
      lang = "und"
      context = json["@context"]
      if context.instance_of?(Array) && context[1]
        base_url = URI.join(url, context[1]["@base"]) if context[1]["@base"]
        lang = context[1]["@language"] if context[1]["@language"]
      end
      json.except!("@context")
      tables = {}
      annotations = {}
      inherited_properties = {}
      warnings = []
      if json["url"]
        json = { "tables" => [ json ] }
      end
      json.each do |property,value|
        unless VALID_PROPERTIES.include? property
          v, warning, type = CsvwPropertyChecker.check_property(property, value, base_url, lang)
          if warning.nil? || warning.empty?
            if type == :annotation
              annotations[property] = v
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
      json["tables"].each do |table_desc|
        table_url = URI.join(url, table_desc["url"]).to_s
        table = Csvlint::CsvwTable.from_json(table_desc, base_url, lang, inherited_properties)
        tables[table_url] = table
      end
      return CsvwTableGroup.new(url, id: json["@id"], tables: tables, notes: json["notes"] || [], annotations: annotations, warnings: warnings)
    end

    private
      VALID_PROPERTIES = ['tables', 'notes', '@context', '@id', '@type']

  end
end

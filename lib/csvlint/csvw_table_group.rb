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
      @validated_tables = {}
      @tables.each { |t,v| @validated_tables[t] = false }
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
      @validated_tables[table_url] = true
      table = tables[table_url]
      table.validate_row(values, row)
      @errors += table.errors
      @warnings += table.warnings
      return valid?
    end

    def validate_foreign_keys
      reset
      unless @validated_tables.has_value?(false)
        @tables.each do |table_url,table|
          table.validate_foreign_keys
          @errors += table.errors
          @warnings += table.warnings
        end
      end
      return valid?
    end

    def CsvwTableGroup.from_json(url, json)
      warnings = []
      tables = {}
      annotations = {}
      inherited_properties = {}
      common_properties = {}
      base_url = url
      lang = "und"

      context = json["@context"]
      if context.instance_of?(Array) && context[1]
        context[1].each do |property,value|
          v, warning, type = CsvwPropertyChecker.check_property(property, value, base_url, lang)
          if warning.nil? || warning.empty?
            if type == :context
              base_url = v if property == "@base"
              lang = v if property == "@language"
            else
              warnings += Csvlint::ErrorMessage.new(:invalid_property, :metadata, nil, nil, "@context: #{property}", nil)
            end
          else
            warnings += Array(warning).map{ |w| Csvlint::ErrorMessage.new(w, :metadata, nil, nil, "@context: #{property}: #{value}", nil) }
          end
        end
      end
      json.except!("@context")

      if json["url"]
        json = { "tables" => [ json ] }
      end unless json["tables"]

      json.each do |property,value|
        unless VALID_PROPERTIES.include? property
          v, warning, type = CsvwPropertyChecker.check_property(property, value, base_url, lang)
          warnings += Array(warning).map{ |w| Csvlint::ErrorMessage.new(w, :metadata, nil, nil, "#{property}: #{value}", nil) } unless warning.nil? || warning.empty?
          if type == :annotation
            annotations[property] = v
          elsif type == :common
            common_properties[property] = v
          elsif type == :column
            warnings << Csvlint::ErrorMessage.new(:invalid_property, :metadata, nil, nil, "#{property}", nil)
          else
            inherited_properties[property] = v
          end
        end
      end

      id = common_properties["@id"]

      raise Csvlint::CsvwMetadataError.new("$.@type"), "@type of table group is not 'TableGroup'" if json["@type"] && json["@type"] != 'TableGroup'

      raise Csvlint::CsvwMetadataError.new("$"), "no tables property" unless json["tables"]
      raise Csvlint::CsvwMetadataError.new("$.tables"), "empty tables property" if json["tables"].empty?
      raise Csvlint::CsvwMetadataError.new("$.tables"), "tables property is not an array" unless json["tables"].instance_of? Array

      json["tables"].each do |table_desc|
        if table_desc.instance_of? Hash
          table_url = table_desc["url"]
          unless table_url.instance_of? String
            warnings << Csvlint::ErrorMessage.new(:invalid_url, :metadata, nil, nil, "url: #{table_url}", nil)
            table_url = ""
          end
          table_url = URI.join(url, table_url).to_s
          table_desc["url"] = table_url
          table = Csvlint::CsvwTable.from_json(table_desc, base_url, lang, inherited_properties)
          tables[table_url] = table
        else
          warnings << Csvlint::ErrorMessage.new(:invalid_table_description, :metadata, nil, nil, "#{table_desc}", nil)
        end
      end

      tables.each do |table_url, table|
        table.foreign_keys.each_with_index do |foreign_key,i|
          reference = foreign_key["reference"]
          if reference["resource"]
            resource = URI.join(url, reference["resource"]).to_s
            referenced_table = tables[resource]
            raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_url}')].tableSchema.foreign_keys[#{i}].reference.resource"), "foreign key references table that does not exist (#{resource})" if referenced_table.nil?
          else
            schema_url = URI.join(url, reference["schemaReference"]).to_s
            referenced_tables = tables.values.select{ |table| table.schema == schema_url }
            referenced_table = referenced_tables[0]
            raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_url}')].tableSchema.foreign_keys[#{i}].reference.schemaReference"), "foreign key references schema that is not used (#{schema_url})" if referenced_table.nil?
          end
          foreign_key["referenced_table"] = referenced_table
          table_columns = {}
          referenced_table.columns.each do |column|
            table_columns[column.name] = column if column.name
          end
          referenced_columns = []
          Array(reference["columnReference"]).each do |column_reference|
            column = table_columns[column_reference]
            raise Csvlint::CsvwMetadataError.new("$.tables[?(@.url = '#{table_url}')].tableSchema.foreign_keys[#{i}].reference.columnReference"), "column named #{column_reference} does not exist in #{resource}" if column.nil?
            referenced_columns << column
          end
          foreign_key["referenced_columns"] = referenced_columns
          referenced_table.foreign_key_references << foreign_key
        end
      end

      return CsvwTableGroup.new(url, id: id, tables: tables, notes: json["notes"] || [], annotations: annotations, warnings: warnings)
    end

    private
      VALID_PROPERTIES = ['tables', 'notes', '@type']

  end
end

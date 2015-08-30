module Csvlint

  class CsvwColumn

    include Csvlint::ErrorCollector

    attr_reader :about_url, :datatype, :default, :lang, :name, :null, :number, :ordered, :property_url, :required, :separator, :source_number, :suppress_output, :text_direction, :titles, :value_url, :virtual, :annotations

    def initialize(number, name, about_url: nil, datatype: "xsd:string", default: "", lang: "und", null: "", ordered: false, property_url: nil, required: false, separator: nil, source_number: nil, suppress_output: false, text_direction: :inherit, titles: {}, value_url: nil, virtual: false, annotations: [], warnings: [])
      @number = number
      @name = name
      @about_url = about_url
      @datatype = datatype
      @default = default
      @lang = lang
      @null = null
      @ordered = ordered
      @property_url = property_url
      @required = required
      @separator = separator
      @source_number = source_number || number
      @suppress_output = suppress_output
      @text_direction = text_direction
      @titles = titles
      @value_url = value_url
      @virtual = virtual
      @annotations = annotations
      reset
      @warnings += warnings
    end

    def validate(string_value, row=nil)
      reset
      values = parse(string_value, row)
      values.each do |value|
        validate_length(value, row)
      end
      return valid?
    end

    def parse(string_value, row=nil)
      return [string_value]
    end

    def CsvwColumn.from_json(number, column_desc, base_url=nil, lang="und", inherited_properties={})
      titles = {}
      titles["und"] = Array(column_desc["titles"]) if column_desc["titles"]
      annotations = {}
      warnings = []
      column_desc.each do |property,value|
        unless VALID_PROPERTIES.include? property
          v, warning, type = CsvwPropertyChecker.check_property(property, value, base_url, lang)
          if warning.nil?
            if type == :annotation
              annotations[property] = v
            else
              inherited_properties[property] = v
            end
          else
            warnings << Csvlint::ErrorMessage.new(warning, :metadata, nil, nil, "#{property}: #{value}", nil)
          end
        end
      end
      datatype = inherited_properties["datatype"] || "xsd:string"
      return CsvwColumn.new(number, column_desc["name"], datatype: datatype, titles: titles, property_url: column_desc["propertyUrl"], required: column_desc["required"] == true, annotations: annotations, warnings: warnings)
    end

    private
      def validate_length(value, row)
        if datatype["minLength"]
          build_errors(:min_length, :schema, row, number, value, { "minLength" => datatype["minLength"] }) if value.length < datatype["minLength"]
        end
      end

      VALID_PROPERTIES = [ 'name', 'titles' ]

  end
end

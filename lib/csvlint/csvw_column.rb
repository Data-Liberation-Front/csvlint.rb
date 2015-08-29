module Csvlint

  class CsvwColumn

    include Csvlint::ErrorCollector

    attr_reader :about_url, :datatype, :default, :lang, :name, :null, :number, :ordered, :property_url, :required, :separator, :source_number, :suppress_output, :text_direction, :titles, :value_url, :virtual, :annotations

    def initialize(number, name, about_url: nil, datatype: "xsd:string", default: "", lang: "und", null: "", ordered: false, property_url: nil, required: false, separator: nil, source_number: nil, suppress_output: false, text_direction: :inherit, titles: {}, value_url: nil, virtual: false, annotations: [])
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
      if @datatype["base"] == "xsd:string" && @datatype["format"]
        begin
          @datatype["format"] = Regexp.new(@datatype["format"])
        rescue RegexpError
          build_warnings(:invalid_regex, :schema, nil, number, ("#{name}: datatype: format: #{@datatype["format"]}"),
            { "format" => @datatype["format"] })
          @datatype["format"] = nil
        end
      end
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

    def CsvwColumn.from_json(number, json)
      titles = {}
      titles["und"] = Array(json["titles"]) if json["titles"]
      datatype = json["datatype"] || "xsd:string"
      if datatype.instance_of? Hash
        if datatype["base"]
          datatype["base"] = "xsd:#{datatype["base"]}" unless datatype["base"] =~ /^http(s)/
        else
          datatype["base"] = "xsd:string"
        end
      end
      return CsvwColumn.new(number, json["name"], datatype: datatype, titles: titles, property_url: json["propertyUrl"], required: json["required"] == true)
    end

    private
      def validate_length(value, row)
        if datatype["minLength"]
          build_errors(:min_length, :schema, row, number, value, { "minLength" => datatype["minLength"] }) if value.length < datatype["minLength"]
        end
      end

      VALID_PROPERTIES = []

  end
end

module Csvlint

  class CsvwColumn

    include Csvlint::ErrorCollector

    attr_reader :id, :about_url, :datatype, :default, :lang, :name, :null, :number, :ordered, :property_url, :required, :separator, :source_number, :suppress_output, :text_direction, :titles, :value_url, :virtual, :annotations

    def initialize(number, name, id: nil, about_url: nil, datatype: "xsd:string", default: "", lang: "und", null: [""], ordered: false, property_url: nil, required: false, separator: nil, source_number: nil, suppress_output: false, text_direction: :inherit, titles: {}, value_url: nil, virtual: false, annotations: [], warnings: [])
      @number = number
      @name = name
      @id = id
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

    def validate_header(header)
      reset
      valid_headers = @titles ? @titles.map{ |l,v| v if CsvwColumn.languages_match(l, lang) }.flatten : []
      build_errors(:invalid_header, :schema, 1, @number, header, @titles) unless valid_headers.include? header
      return valid?
    end

    def validate(string_value, row=nil)
      reset
      value = parse(string_value, row)
      # STDERR.puts "#{name} - #{string_value} - #{value.inspect} - #{null}"
      Array(value).each do |value|
        validate_required(value, row)
        validate_format(value, row)
        validate_length(value, row)
      end unless value.nil?
      validate_required(value, row) if value.nil?
      return valid?
    end

    def parse(string_value, row=nil)
      return nil if null.include? string_value
      return string_value
    end

    def CsvwColumn.from_json(number, column_desc, base_url=nil, lang="und", inherited_properties={})
      annotations = {}
      warnings = []
      column_properties = {}
      inherited_properties = inherited_properties.clone

      column_desc.each do |property,value|
        if property == "@type"
          raise Csvlint::CsvwMetadataError.new("columns[#{number}].@type"), "@type of column is not 'Column'" if value != 'Column'
        else
          v, warning, type = CsvwPropertyChecker.check_property(property, value, base_url, lang)
          warnings += Array(warning).map{ |w| Csvlint::ErrorMessage.new(w, :metadata, nil, nil, "#{property}: #{value}", nil) } unless warning.nil? || warning.empty?
          if type == :annotation
            annotations[property] = v
          elsif type == :common || type == :column
            column_properties[property] = v
          elsif type == :inherited
            inherited_properties[property] = v
          else
            warnings << Csvlint::ErrorMessage.new(:invalid_property, :metadata, nil, nil, "column: #{property}", nil)
          end
        end
      end

      return CsvwColumn.new(number, column_properties["name"], 
        id: column_properties["@id"], 
        datatype: inherited_properties["datatype"] || { "@id" => "http://www.w3.org/2001/XMLSchema#string" }, 
        lang: inherited_properties["lang"] || "und",
        null: inherited_properties["null"] || [""],
        property_url: column_desc["propertyUrl"], 
        required: inherited_properties["required"] || false, 
        titles: column_properties["titles"], 
        virtual: column_properties["virtual"] || false,
        annotations: annotations, 
        warnings: warnings
      )
    end

    private
      def CsvwColumn.languages_match(l1, l2)
        return true if l1 == l2 || l1 == "und" || l2 == "und"
        return true if l1 =~ Regexp.new("^#{l2}-") || l2 =~ Regexp.new("^#{l1}-")
        return false
      end

      def validate_required(value, row)
        build_errors(:required, :schema, row, number, value, { "required" => @required }) if @required && value.nil?
      end

      def validate_length(value, row)
        if datatype["minLength"]
          build_errors(:min_length, :schema, row, number, value, { "minLength" => datatype["minLength"] }) if value.length < datatype["minLength"]
        end
      end

      def validate_format(value, row)
        if datatype["format"]
          build_errors(:format, :schema, row, number, value, { "format" => datatype["format"] }) unless DATATYPE_FORMAT_VALIDATION[datatype["base"]].call(value, datatype["format"])
        end
      end

      REGEXP_VALIDATION = lambda { |value, format| value =~ format }

      NUMBER_FORMAT_VALIDATION = lambda { |value, format| 
        if format["groupChar"] && !format["pattern"]
          return true
        else
          group_char = format["groupChar"] || ","
          decimal_char = format["decimalChar"] || "."
          
          return true
        end
      }

      BOOLEAN_FORMAT_VALIDATION = lambda { |value, format| true }

      DATE_FORMAT_VALIDATION = lambda { |value, format| true }

      DATATYPE_FORMAT_VALIDATION = {
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral" => REGEXP_VALIDATION,
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML" => REGEXP_VALIDATION,
        "http://www.w3.org/ns/csvw#JSON" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#anyAtomicType" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#anyURI" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#base64Binary" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#boolean" => BOOLEAN_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#date" => DATE_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#dateTime" => DATE_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#dateTimeStamp" => DATE_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#decimal" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#integer" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#long" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#int" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#short" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#byte" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#nonNegativeInteger" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#positiveInteger" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#unsignedLong" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#unsignedInt" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#unsignedShort" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#unsignedByte" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#nonPositiveInteger" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#negativeInteger" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#double" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#duration" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#dayTimeDuration" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#yearMonthDuration" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#float" => NUMBER_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#gDay" => DATE_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#gMonth" => DATE_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#gMonthDay" => DATE_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#gYear" => DATE_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#gYearMonth" => DATE_FORMAT_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#hexBinary" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#QName" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#string" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#normalizedString" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#token" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#language" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#Name" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#NMTOKEN" => REGEXP_VALIDATION,
        "http://www.w3.org/2001/XMLSchema#time" => DATE_FORMAT_VALIDATION
      }

  end
end

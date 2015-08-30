module Csvlint
  class CsvwPropertyChecker

    def CsvwPropertyChecker.check_property(property, value, base_url, lang)
      if PROPERTIES.include? property
        return PROPERTIES[property].call(value, base_url, lang)
      elsif property =~ /^([a-z]+):/ && NAMESPACES.include?(property.split(":")[0])
        return value, nil, :annotation
      else
        return value, :invalid_property, nil
      end
    end

    private
      def CsvwPropertyChecker.boolean_property(type)
        return lambda { |value, base_url, lang|
          return value, nil, type if value == true || value == false
          return false, :invalid_value, type
        }
      end

      def CsvwPropertyChecker.string_property(type)
        return lambda { |value, base_url, lang|
          return value, nil, type if value.instance_of? String
          return "", :invalid_value, type
        }
      end

      PROPERTIES = {
        # inherited properties
        "null" => string_property(:inherited),
        "default" => string_property(:inherited),
        "separator" => lambda { |value, base_url, lang|
          return value, nil, :inherited if value.instance_of?(String) || value.nil?
          return nil, :invalid_value, :inherited
        },
        "lang" => lambda { |value, base_url, lang|
          return value, nil, :inherited if value =~ BCP47_REGEX
          return nil, :invalid_value, :inherited
        },
        "datatype" => lambda { |value, base_url, lang|
          value = value.clone
          warnings = []
          if value.instance_of? Hash
            if value["base"]
              if BUILT_IN_DATATYPES.include? value["base"]
                value["base"] = BUILT_IN_DATATYPES[value["base"]]
              else
                value["base"] = BUILT_IN_DATATYPES["string"]
                warnings << :invalid_datatype_base
              end
            else
              value["base"] = BUILT_IN_DATATYPES["string"]
            end
          elsif BUILT_IN_DATATYPES.include? value
            value = { "@id" => BUILT_IN_DATATYPES[value] }
          else
            value = { "@id" => BUILT_IN_DATATYPES["string"] }
            warnings << :invalid_value
          end
          if value["base"] == BUILT_IN_DATATYPES["string"] && value["format"]
            begin
              value["format"] = Regexp.new(value["format"])
            rescue RegexpError
              value["format"] = nil
              warnings << :invalid_regex
            end
          end
          return value, warnings, :inherited
        },
        "required" => boolean_property(:inherited),
        "ordered" => boolean_property(:inherited),
        "aboutUrl" => string_property(:inherited),
        "propertyUrl" => string_property(:inherited),
        "valueUrl" => string_property(:inherited),
        "textDirection" => lambda { |value, base_url, lang| 
          value = value.to_sym
          return value, nil, :inherited if [:ltr, :rtl, :auto, :inherit].include? value
          return :inherit, :invalid_value, :inherited
        },
        # column level properties
        "virtual" => boolean_property(:column),
        # table level properties
        "transformations" => lambda { |value, base_url, lang| return value, nil, :table },
        "tableDirection" => lambda { |value, base_url, lang| return value, nil, :table },
        "tableSchema" => lambda { |value, base_url, lang| 
          if value.instance_of? String
            table_schema_url = URI.join(base_url, value)
            table_schema = JSON.parse( open(table_schema_url).read )
            return table_schema, nil, :table
          else
            return value, nil, :table 
          end
        },
        "dialect" => lambda { |value, base_url, lang| 
          value = value.clone
          if value.instance_of? Hash
            warnings = []
            value.each do |p,v|
              v, warning, type = check_property(p, v, base_url, lang)
              unless type == :dialect && (warning.nil? || warning.empty?)
                value.except!(p)
                warnings << :invalid_property unless type == :dialect
                warnings += Array(warning)
              end
            end
            return value, warnings, :table 
          else
            return nil, :invalid_value, :table
          end
        },
        # dialect properties
        "commentPrefix" => string_property(:dialect)
      }

      NAMESPACES = {
        "dcat" => "http://www.w3.org/ns/dcat#",
        "qb" => "http://purl.org/linked-data/cube#",
        "grddl" => "http://www.w3.org/2003/g/data-view#",
        "ma" => "http://www.w3.org/ns/ma-ont#",
        "org" => "http://www.w3.org/ns/org#",
        "owl" => "http://www.w3.org/2002/07/owl#",
        "prov" => "http://www.w3.org/ns/prov#",
        "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdfa" => "http://www.w3.org/ns/rdfa#",
        "rdfs" => "http://www.w3.org/2000/01/rdf-schema#",
        "rif" => "http://www.w3.org/2007/rif#",
        "rr" => "http://www.w3.org/ns/r2rml#",
        "sd" => "http://www.w3.org/ns/sparql-service-description#",
        "skos" => "http://www.w3.org/2004/02/skos/core#",
        "skosxl" => "http://www.w3.org/2008/05/skos-xl#",
        "wdr" => "http://www.w3.org/2007/05/powder#",
        "void" => "http://rdfs.org/ns/void#",
        "wdrs" => "http://www.w3.org/2007/05/powder-s#",
        "xhv" => "http://www.w3.org/1999/xhtml/vocab#",
        "xml" => "http://www.w3.org/XML/1998/namespace",
        "xsd" => "http://www.w3.org/2001/XMLSchema#",
        "cc" => "http://creativecommons.org/ns#",
        "ctag" => "http://commontag.org/ns#",
        "dc" => "http://purl.org/dc/terms/",
        "dcterms" => "http://purl.org/dc/terms/",
        "dc11" => "http://purl.org/dc/elements/1.1/",
        "foaf" => "http://xmlns.com/foaf/0.1/",
        "gr" => "http://purl.org/goodrelations/v1#",
        "ical" => "http://www.w3.org/2002/12/cal/icaltzd#",
        "og" => "http://ogp.me/ns#",
        "rev" => "http://purl.org/stuff/rev#",
        "sioc" => "http://rdfs.org/sioc/ns#",
        "v" => "http://rdf.data-vocabulary.org/#",
        "vcard" => "http://www.w3.org/2006/vcard/ns#",
        "schema" => "http://schema.org/"
      }

      BCP47_REGULAR_REGEX = "(art-lojban|cel-gaulish|no-bok|no-nyn|zh-guoyu|zh-hakka|zh-min|zh-min-nan|zh-xiang)"
      BCP47_IRREGULAR_REGEX = "(en-GB-oed|i-ami|i-bnn|i-default|i-enochian|i-hak|i-klingon|i-lux|i-mingo|i-navajo|i-pwn|i-tao|i-tay|i-tsu|sgn-BE-FR|sgn-BE-NL|sgn-CH-DE)"
      BCP47_GRANDFATHERED_REGEX = "(?<grandfathered>" + BCP47_IRREGULAR_REGEX + "|" + BCP47_REGULAR_REGEX + ")"
      BCP47_PRIVATE_USE_REGEX = "(?<privateUse>x(-[A-Za-z0-9]{1,8})+)"
      BCP47_SINGLETON_REGEX = "[0-9A-WY-Za-wy-z]"
      BCP47_EXTENSION_REGEX = "(?<extension>" + BCP47_SINGLETON_REGEX + "(-[A-Za-z0-9]{2,8})+)"
      BCP47_VARIANT_REGEX = "(?<variant>[A-Za-z0-9]{5,8}|[0-9][A-Za-z0-9]{3})"
      BCP47_REGION_REGEX = "(?<region>[A-Za-z]{2}|[0-9]{3})"
      BCP47_SCRIPT_REGEX = "(?<script>[A-Za-z]{4})"
      BCP47_EXTLANG_REGEX = "(?<extlang>[A-Za-z]{3}(-[A-Za-z]{3}){0,2})"
      BCP47_LANGUAGE_REGEX = "(?<language>([A-Za-z]{2,3}(-" + BCP47_EXTLANG_REGEX + ")?)|[A-Za-z]{4}|[A-Za-z]{5,8})"
      BCP47_LANGTAG_REGEX = "(" + BCP47_LANGUAGE_REGEX + "(-" + BCP47_SCRIPT_REGEX + ")?" + "(-" + BCP47_REGION_REGEX + ")?" + "(-" + BCP47_VARIANT_REGEX + ")*" + "(-" + BCP47_EXTENSION_REGEX + ")*" + "(-" + BCP47_PRIVATE_USE_REGEX + ")?" + ")"
      BCP47_LANGUAGETAG_REGEX = "^(" + BCP47_GRANDFATHERED_REGEX + "|" + BCP47_LANGTAG_REGEX + "|" + BCP47_PRIVATE_USE_REGEX + ")$"
      BCP47_REGEX = Regexp.new(BCP47_LANGUAGETAG_REGEX)

      BUILT_IN_DATATYPES = {
        "number" => "http://www.w3.org/2001/XMLSchema#double",
        "binary" => "http://www.w3.org/2001/XMLSchema#base64Binary",
        "datetime" => "http://www.w3.org/2001/XMLSchema#dateTime",
        "any" => "http://www.w3.org/2001/XMLSchema#anyAtomicType",
        "xml" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral",
        "html" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML",
        "json" => "http://www.w3.org/ns/csvw#JSON",
        "anyAtomicType" => "http://www.w3.org/2001/XMLSchema#anyAtomicType",
        "anyURI" => "http://www.w3.org/2001/XMLSchema#anyURI",
        "base64Binary" => "http://www.w3.org/2001/XMLSchema#base64Binary",
        "boolean" => "http://www.w3.org/2001/XMLSchema#boolean",
        "date" => "http://www.w3.org/2001/XMLSchema#date",
        "dateTime" => "http://www.w3.org/2001/XMLSchema#dateTime",
        "dateTimeStamp" => "http://www.w3.org/2001/XMLSchema#dateTimeStamp",
        "decimal" => "http://www.w3.org/2001/XMLSchema#decimal",
        "integer" => "http://www.w3.org/2001/XMLSchema#integer",
        "long" => "http://www.w3.org/2001/XMLSchema#long",
        "int" => "http://www.w3.org/2001/XMLSchema#int",
        "short" => "http://www.w3.org/2001/XMLSchema#short",
        "byte" => "http://www.w3.org/2001/XMLSchema#byte",
        "nonNegativeInteger" => "http://www.w3.org/2001/XMLSchema#nonNegativeInteger",
        "positiveInteger" => "http://www.w3.org/2001/XMLSchema#positiveInteger",
        "unsignedLong" => "http://www.w3.org/2001/XMLSchema#unsignedLong",
        "unsignedInt" => "http://www.w3.org/2001/XMLSchema#unsignedInt",
        "unsignedShort" => "http://www.w3.org/2001/XMLSchema#unsignedShort",
        "unsignedByte" => "http://www.w3.org/2001/XMLSchema#unsignedByte",
        "nonPositiveInteger" => "http://www.w3.org/2001/XMLSchema#nonPositiveInteger",
        "negativeInteger" => "http://www.w3.org/2001/XMLSchema#negativeInteger",
        "double" => "http://www.w3.org/2001/XMLSchema#double",
        "duration" => "http://www.w3.org/2001/XMLSchema#duration",
        "dayTimeDuration" => "http://www.w3.org/2001/XMLSchema#dayTimeDuration",
        "yearMonthDuration" => "http://www.w3.org/2001/XMLSchema#yearMonthDuration",
        "float" => "http://www.w3.org/2001/XMLSchema#float",
        "gDay" => "http://www.w3.org/2001/XMLSchema#gDay",
        "gMonth" => "http://www.w3.org/2001/XMLSchema#gMonth",
        "gMonthDay" => "http://www.w3.org/2001/XMLSchema#gMonthDay",
        "gYear" => "http://www.w3.org/2001/XMLSchema#gYear",
        "gYearMonth" => "http://www.w3.org/2001/XMLSchema#gYearMonth",
        "hexBinary" => "http://www.w3.org/2001/XMLSchema#hexBinary",
        "QName" => "http://www.w3.org/2001/XMLSchema#QName",
        "string" => "http://www.w3.org/2001/XMLSchema#string",
        "normalizedString" => "http://www.w3.org/2001/XMLSchema#normalizedString",
        "token" => "http://www.w3.org/2001/XMLSchema#token",
        "language" => "http://www.w3.org/2001/XMLSchema#language",
        "Name" => "http://www.w3.org/2001/XMLSchema#Name",
        "NMTOKEN" => "http://www.w3.org/2001/XMLSchema#NMTOKEN",
        "time" => "http://www.w3.org/2001/XMLSchema#time"
      }
  end
end
                                                                                                                                                                                                                                                            """"""""""""""""""
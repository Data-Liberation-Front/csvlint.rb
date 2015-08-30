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
          return value, nil, :inherited
        },
        "datatype" => lambda { |value, base_url, lang|
          warning = nil
          if value.instance_of? Hash
            if value["base"]
              value["base"] = "xsd:#{value["base"]}" unless value["base"] =~ /^http(s)/
            else
              value["base"] = "xsd:string"
            end
          else
            value = { "@id" => "xsd:#{value}" }
          end
          if value["base"] == "xsd:string" && value["format"]
            begin
              value["format"] = Regexp.new(value["format"])
            rescue RegexpError
              value["format"] = nil
              warning = :invalid_regex
            end
          end
          return value, warning, :inherited
        },
        "required" => boolean_property(:inherited),
        "ordered" => boolean_property(:inherited),
        "aboutUrl" => lambda { |value, base_url, lang| return value, nil, :inherited },
        "propertyUrl" => lambda { |value, base_url, lang| return value, nil, :inherited },
        "valueUrl" => lambda { |value, base_url, lang| return value, nil, :inherited },
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
        "dialect" => lambda { |value, base_url, lang| return value, nil, :table }
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
  end
end
                                                                                                                                                                                                                                                            """"""""""""""""""
module Csvlint
  module Csvw
    class JSONTransformer

      include Csvlint::ErrorCollector

      attr_reader :result, :minimal

      def initialize(source, dialect = {}, schema = nil, options = {})
        reset
        @source = source
        @result = {
          "tables" => []
        }
        @minimal = options[:minimal] || false

        if schema.nil?
          @result["tables"].push({ "url" => @source })
          @rownum = 0
          @columns = []

          @validator = Csvlint::Validator.new( @source, dialect, schema, { :lambda => lambda { |v| transform(v) } } )
          @errors += @validator.errors
          @warnings += @validator.warnings
        else
          schema.tables.keys.each do |table_url|
            @source = table_url
            @result["tables"].push({ "url" => @source })
            @rownum = 0
            @columns = []

            @validator = Csvlint::Validator.new( @source, dialect, schema, { :lambda => lambda { |v| transform(v) } } )
            @errors += @validator.errors
            @warnings += @validator.warnings
          end
        end

        @result = @result["tables"].map { |t| t["row"].map { |r| r["describes"] } }.flatten if @minimal
      end

      private
        def transform(v)
          if @columns.empty?
            initialize_result(v)
          end
          if v.current_line > v.dialect["headerRowCount"]
            @rownum += 1
            rowdata = transform_data(v.data[-1], v.current_line)
            row = {
              "url" => "#{@source}#row=#{v.current_line}",
              "rownum" => @rownum,
              "describes" => rowdata
            }
            @result["tables"][-1]["row"] << row
          end
        end

        def initialize_result(v)
          if v.schema.nil?
            v.data[0].each_with_index do |h,i|
              @columns.push Csvlint::Csvw::Column.new(i+1, h)
            end
          else
            table = v.schema.tables[@source]
            table.annotations.each do |a,v|
              @result["tables"][-1][a] = JSONTransformer.transform_annotation(v)
            end
            if table.columns.empty?
              v.data[0].each_with_index do |h,i|
                @columns.push Csvlint::Csvw::Column.new(i+1, "_col.#{i+1}")
              end
            else
              @columns = table.columns
            end
          end
          @result["tables"][-1]["row"] = []
        end

        def transform_data(data, sourceRow)
          values = {}
          @columns.each_with_index do |column,i|
            unless data[i].nil?
              base_type = column.datatype["@base"] || column.datatype["@id"]
              if NUMERIC_DATATYPES.include? base_type
                v = data[i]
              elsif base_type == "http://www.w3.org/2001/XMLSchema#boolean"
                v = data[i] 
              elsif base_type == "http://www.w3.org/2001/XMLSchema#gYear"
                v = data[i]["year"].to_s
              else
                v = data[i].to_s
              end
              values[column.name] = v
            end
          end
          values["_row"] = @rownum
          values["_sourceRow"] = sourceRow

          objects = {}
          @columns.each_with_index do |column,i|
            values["_column"] = i
            values["_sourceColumn"] = i
            values["_name"] = column.name

            object_id = column.about_url ? URI.join(@source, column.about_url.expand(values)).to_s : nil
            if objects[object_id].nil?
              objects[object_id] = {}
              objects[object_id]["@id"] = object_id unless object_id.nil?
            end

            property = property(column, values)
            value = column.value_url ? URI.join(@source, column.value_url.expand(values)).to_s : values[column.name]
            objects[object_id][property] = value unless value.nil?
          end

          return objects.values
        end

        def property(column, values)
          if column.property_url
            url = URI.join(@source, column.property_url.expand(values)).to_s
            NAMESPACES.each do |prefix,ns|
              url.gsub!(Regexp.new("^#{Regexp.escape(ns)}$"), "#{prefix}")
              url.gsub!(Regexp.new("^#{Regexp.escape(ns)}"), "#{prefix}:")
            end
            return url
          else
            return column.name
          end
        end

        def JSONTransformer.transform_annotation(value)
          if value.instance_of? Hash
            if value["@id"]
              return value["@id"].to_s
            elsif value["@type"]
              return value["@value"]
            else
              result = {}
              value.each do |a,v|
                result[a] = transform_annotation(v)
              end
              return result
            end
          else
            return value
          end 
        end

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

        BINARY_DATATYPES = [
          "http://www.w3.org/2001/XMLSchema#base64Binary",
          "http://www.w3.org/2001/XMLSchema#hexBinary"
        ]

        NUMERIC_DATATYPES = [
          "http://www.w3.org/2001/XMLSchema#decimal",
          "http://www.w3.org/2001/XMLSchema#integer",
          "http://www.w3.org/2001/XMLSchema#long",
          "http://www.w3.org/2001/XMLSchema#int",
          "http://www.w3.org/2001/XMLSchema#short",
          "http://www.w3.org/2001/XMLSchema#byte",
          "http://www.w3.org/2001/XMLSchema#nonNegativeInteger",
          "http://www.w3.org/2001/XMLSchema#positiveInteger",
          "http://www.w3.org/2001/XMLSchema#unsignedLong",
          "http://www.w3.org/2001/XMLSchema#unsignedInt",
          "http://www.w3.org/2001/XMLSchema#unsignedShort",
          "http://www.w3.org/2001/XMLSchema#unsignedByte",
          "http://www.w3.org/2001/XMLSchema#nonPositiveInteger",
          "http://www.w3.org/2001/XMLSchema#negativeInteger",
          "http://www.w3.org/2001/XMLSchema#double",
          "http://www.w3.org/2001/XMLSchema#float"
        ]

    end
  end
end

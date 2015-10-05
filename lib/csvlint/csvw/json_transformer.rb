module Csvlint
  module Csvw
    class JSONTransformer

      include Csvlint::ErrorCollector

      attr_reader :result, :minimal, :validate

      def initialize(source, dialect = {}, schema = nil, options = {})
        reset
        @source = source
        @result = {
          "tables" => []
        }
        @minimal = options[:minimal] || false
        @validate = options[:validate] || false

        if schema.nil?
          @result["tables"].push({ "url" => @source })
          @rownum = 0
          @columns = []

          @validator = Csvlint::Validator.new( @source, dialect, schema, { :validate => @validate, :lambda => lambda { |v| transform(v) } } )
          @errors += @validator.errors
          @warnings += @validator.warnings
        else
          schema.annotations.each do |a,v|
            @result[a] = JSONTransformer.transform_annotation(v)
          end
          schema.tables.each do |table_url, table|
            @source = table_url
            @result["tables"].push({ "url" => @source }) unless table.suppress_output
            @rownum = 0
            @columns = []

            @validator = Csvlint::Validator.new( @source, dialect, schema, { :validate => @validate, :lambda => table.suppress_output ? lambda { |a| nil } : lambda { |v| transform(v) } } )
            @errors += @validator.errors
            @warnings += @validator.warnings
          end
        end

        @result = @result["tables"].map { |t| t["row"].map { |r| r["describes"] } }.flatten if @minimal
      end

      private
        def transform(v)
          return nil unless v.errors.empty?
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
            @result["tables"][-1]["@id"] = table.id.to_s if table.id
            table.annotations.each do |a,v|
              @result["tables"][-1][a] = JSONTransformer.transform_annotation(v)
            end
            @result["tables"][-1]["notes"] = JSONTransformer.transform_annotation(table.notes) unless table.notes.empty?
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
              column_name = column.name || column.default_name
              base_type = column.datatype["base"] || column.datatype["@id"]
              if data[i].is_a? Array
                v = []
                data[i].each do |d|
                  v << JSONTransformer.value_to_json(d, base_type)
                end
              else
                v = JSONTransformer.value_to_json(data[i], base_type)
              end
              values[column_name] = v
            end
          end
          values["_row"] = @rownum
          values["_sourceRow"] = sourceRow

          objects = {}
          value_urls_appearing_once = []
          value_urls_appearing_many_times = []
          @columns.each_with_index do |column,i|
            unless column.suppress_output
              column_name = column.name || column.default_name
              values["_column"] = i
              values["_sourceColumn"] = i
              values["_name"] = column_name

              object_id = column.about_url ? URI.join(@source, column.about_url.expand(values)).to_s : nil
              if objects[object_id].nil?
                objects[object_id] = {}
                objects[object_id]["@id"] = object_id unless object_id.nil?
              end

              property = property(column, values)

              if column.value_url
                value = value(column, values, property == "@type")
                unless property == "@type" || value.nil? || value_urls_appearing_many_times.include?(value.to_s)
                  if value_urls_appearing_once.include? value.to_s
                    value_urls_appearing_many_times.push(value.to_s)
                    value_urls_appearing_once.delete(value.to_s)
                  else
                    value_urls_appearing_once.push(value.to_s)
                  end
                end
              else
                value = values[column_name]
              end

              unless value.nil?
                if objects[object_id][property]
                  objects[object_id][property] = [objects[object_id][property]] unless objects[object_id][property].is_a? Array
                  objects[object_id][property] << value
                else
                  objects[object_id][property] = value
                end
              end
            end
          end

          return nest(objects, value_urls_appearing_once, value_urls_appearing_many_times)
        end

        def property(column, values)
          if column.property_url
            url = column.property_url.expand(values)
            url = URI.join(@source, url).to_s
            url = JSONTransformer.compact_url(url)
            url = "@type" if url == "rdf:type"
            return url
          else
            return column.name || column.default_name
          end
        end

        def value(column, values, compact)
          if values[column.name || column.default_name].nil? && !column.virtual
            return nil
          else
            url = column.value_url.expand(values)
            url = JSONTransformer.expand_prefixes(url) unless compact
            url = URI.join(@source, url)
            return url
          end
        end

        def nest(objects, value_urls_appearing_once, value_urls_appearing_many_times)
          root_objects = []
          root_object_urls = []
          first_object_url = nil
          objects.each do |url,object|
            first_object_url = url if first_object_url.nil?
            if value_urls_appearing_many_times.include? url
              root_object_urls << url
            elsif !(value_urls_appearing_once.include? url)
              root_object_urls << url
            end
          end
          root_object_urls << first_object_url if root_object_urls.empty?

          root_object_urls.each do |url|
            root_objects << nest_recursively(objects[url], root_object_urls, objects)
          end
          return root_objects
        end

        def nest_recursively(object, root_object_urls, objects)
          object.each do |prop,value|
            if value.is_a? URI
              if root_object_urls.include?(value.to_s) || objects[value.to_s].nil?
                object[prop] = value.to_s
              else
                object[prop] = nest_recursively(objects[value.to_s], root_object_urls, objects)
              end
            elsif value.is_a? Hash
              object[prop] = nest_recursively(value, root_object_urls, objects)
            end
          end
          return object
        end

        def JSONTransformer.value_to_json(value, base_type)
          if NUMERIC_DATATYPES.include? base_type
            return value
          elsif base_type == "http://www.w3.org/2001/XMLSchema#boolean"
            return value
          elsif base_type == "http://www.w3.org/2001/XMLSchema#dateTime"
            return value.to_s.sub!(/\+00:00$/, "")
          elsif base_type == "http://www.w3.org/2001/XMLSchema#gYear"
            return value["year"].to_s
          else
            return value.to_s
          end
        end

        def JSONTransformer.transform_annotation(value)
          case value
          when Hash
            if value["@id"]
              return value["@id"].to_s
            elsif value["@value"]
              return value["@value"]
            else
              result = {}
              value.each do |a,v|
                result[a] = transform_annotation(v)
              end
              return result
            end
          when Array
            result = []
            value.each do |v|
              result << transform_annotation(v)
            end
            return result
          else
            return value
          end 
        end

        def JSONTransformer.expand_prefixes(url)
          NAMESPACES.each do |prefix,ns|
            url.gsub!(Regexp.new("^#{Regexp.escape(prefix)}:"), "#{ns}")
          end
          return url
        end

        def JSONTransformer.compact_url(url)
          NAMESPACES.each do |prefix,ns|
            url.gsub!(Regexp.new("^#{Regexp.escape(ns)}$"), "#{prefix}")
            url.gsub!(Regexp.new("^#{Regexp.escape(ns)}"), "#{prefix}:")
          end
          return url
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

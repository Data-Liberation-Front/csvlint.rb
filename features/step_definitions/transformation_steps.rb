When(/^I transform the CSV into JSON$/) do
  @csv_options ||= default_csv_options

  begin
    if @schema_json
      json = JSON.parse(@schema_json)
      if @schema_type == :json_table
        @schema = Csvlint::Schema.from_json_table( @schema_url || "http://example.org ", json )
      else
        @schema = Csvlint::Schema.from_csvw_metadata( @schema_url || "http://example.org ", json )
      end
    end

    if @url.nil?
      @errors = []
      @warnings = []
      @schema.tables.keys.each do |table_url|
        transformer = Csvlint::CsvwJSONTransformer.new( table_url, @csv_options, @schema )
        @json = transformer.result
        @errors += transformer.errors
        @warnings += transformer.warnings
      end
    else
      transformer = Csvlint::CsvwJSONTransformer.new( @url, @csv_options, @schema )
      @json = transformer.result
      @errors = transformer.errors
      @warnings = transformer.warnings
    end
  rescue JSON::ParserError => e
    @errors = [e]
  rescue Csvlint::CsvwMetadataError => e
    @errors = [e]
  end
end

Then(/^the JSON should match that in "(.*?)"$/) do |filename|
  content = File.read( File.join( File.dirname(__FILE__), "..", "fixtures", filename ) )
  json = JSON.parse(content)
  expect(json).to eq(@json)
end
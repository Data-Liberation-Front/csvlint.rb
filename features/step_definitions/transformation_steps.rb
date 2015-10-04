When(/^I transform the CSV into JSON( in minimal mode)?$/) do |minimal|
  @csv_options ||= default_csv_options
  minimal = minimal == " in minimal mode"

  begin
    if @schema_json
      json = JSON.parse(@schema_json)
      if @schema_type == :json_table
        @schema = Csvlint::Schema.from_json_table( @schema_url || "http://example.org ", json )
      else
        @schema = Csvlint::Schema.from_csvw_metadata( @schema_url || "http://example.org ", json )
      end
    end

    transformer = Csvlint::Csvw::JSONTransformer.new( @url, @csv_options, @schema, { :minimal => minimal } )
    @json = transformer.result
    @errors = transformer.errors
    @warnings = transformer.warnings
  rescue JSON::ParserError => e
    @errors = [e]
  rescue Csvlint::Csvw::MetadataError => e
    @errors = [e]
  end
end

Then(/^the JSON should match that in "(.*?)"$/) do |filename|
  content = File.read( File.join( File.dirname(__FILE__), "..", "fixtures", filename ) )
  json = JSON.parse(content)
  expect(@json).to eq(json)
end
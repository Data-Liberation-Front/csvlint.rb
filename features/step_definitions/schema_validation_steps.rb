Given(/^I have a schema with the following content:$/) do |json|
  @schema_type = :json_table
  @schema_json = json
end

Given(/^I have metadata with the following content:$/) do |json|
  @schema_type = :csvw_metadata
  @schema_json = json
end

Given(/^I have a metadata file called "([^"]*)"$/) do |filename|
  @schema_type = :csvw_metadata
  @schema_json = File.read( File.join( File.dirname(__FILE__), "..", "fixtures", filename ) )
end

Given(/^the (schema|metadata) is stored at the url "(.*?)"$/) do |schema_type,schema_url|
  @schema_url = schema_url
end

Given(/^there is a file at "(.*?)" with the content:$/) do |url, content|
  stub_request(:get, url).to_return(:status => 200, :body => content.to_str)
end

Given(/^I have a file called "(.*?)" at the url "(.*?)"$/) do |filename,url|
  content = File.read( File.join( File.dirname(__FILE__), "..", "fixtures", filename ) )
  stub_request(:get, url).to_return(:status => 200, :body => content)
end
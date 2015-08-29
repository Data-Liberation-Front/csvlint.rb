Given(/^I have a schema with the following content:$/) do |json|
  @schema_type = :json_table
  @schema_json = json
end

Given(/^I have metadata with the following content:$/) do |json|
  @schema_type = :csvw_metadata
  @schema_json = json
end

Given(/^the (schema|metadata) is stored at the url "(.*?)"$/) do |schema_type,schema_url|
  @schema_url = schema_url
end

Given(/^there is a file at "(.*?)" with the content:$/) do |url, content|
  stub_request(:get, url).to_return(:status => 200, :body => content.to_str)
end
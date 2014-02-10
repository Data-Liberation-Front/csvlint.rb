Given(/^I have a schema with the following content:$/) do |json|
  @schema_json = json
end

Given(/^the schema is stored at the url "(.*?)"$/) do |schema_url|
  @schema_url = schema_url
end
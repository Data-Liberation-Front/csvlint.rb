Given(/^I ask if there are info messages$/) do
  @csv_options ||= default_csv_options
  
  if @schema_json
    @schema = Csvlint::Schema.from_json_table( @schema_url || "http://example.org ", JSON.parse(@schema_json) )
  end
  
  @validator = Csvlint::Validator.new( @url, @csv_options, @schema ) 
  @info_messages = @validator.info_messages
end

Then(/^there should be (\d+) info messages?$/) do |num|
  @info_messages.count.should == num.to_i
end

Then(/^that message should have the type "(.*?)"$/) do |msg_type|
  @info_messages.first.type.should == msg_type.to_sym
end
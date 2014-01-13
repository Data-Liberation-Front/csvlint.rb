Given(/^it is encoded as "(.*?)"$/) do |encoding|
  @csv = @csv.encode(encoding)
  @encoding = encoding
end

Given(/^I set an encoding header of "(.*?)"$/) do |encoding|
  @encoding = encoding
end

Given(/^I do not set an encoding header$/) do
  @encoding = nil
end

Given(/^I have a CSV file called "(.*?)"$/) do |filename|
  @csv = File.read( File.join( File.dirname(__FILE__), "..", "fixtures", filename ) )
end

When(/^I ask if there are warnings$/) do
  @validator = Csvlint::Validator.new( @url, @csv_options ) 
  @warnings = @validator.warnings
end

Then(/^there should be (\d+) warnings$/) do |count|
  @warnings.count.should == count.to_i
end

Given(/^the content type is set to "(.*?)"$/) do |type|
  @content_type = type
end

Then(/^that warning should have the position "(.*?)"$/) do |position|
  @warnings.first[:position].should == position.to_i
end

Then(/^that warning should have the type "(.*?)"$/) do |type|
  @warnings.first[:type].should == type.to_sym
end
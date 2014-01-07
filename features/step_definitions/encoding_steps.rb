Given(/^it is encoded as "(.*?)"$/) do |encoding|
  @csv = @csv.encode(encoding)
  @encoding = encoding
end

When(/^I ask if there are warnings$/) do
  @validator = Csvlint::Validator.new( @url ) 
  @warnings = @validator.warnings
end

Then(/^there should be (\d+) warnings$/) do |count|
  @warnings.count.should == count.to_i
end

When(/^I ask for the encoding$/) do
  @validator = Csvlint::Validator.new( @url ) 
end

Then(/^I should get "(.*?)"$/) do |encoding|
  @validator.encoding.should == encoding
end
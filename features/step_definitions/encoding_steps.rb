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

Then(/^it should have guessed an encoding of "(.*?)"$/) do |encoding|
  expect( @validator.guessed_encoding ).to_not be(nil)
  expect( @validator.guessed_encoding[:encoding] ).to eql(encoding)
end

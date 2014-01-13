When(/^I ask if there are errors$/) do
  @validator = Csvlint::Validator.new( @url ) 
  @errors = @validator.errors
end

Then(/^there should be (\d+) error$/) do |count|
  @errors.count.should == count.to_i
end

Then(/^that error should have the type "(.*?)"$/) do |type|
  @errors.first[:type].should == type.to_sym
end

Then(/^that error should have the row "(.*?)"$/) do |row|
  @errors.first[:row].should == row.to_i
end
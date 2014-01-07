Given(/^the content type is "(.*?)"$/) do |arg1|
  @content_type = "text/csv"
end

Then(/^the encoding should be "(.*?)"$/) do |encoding|
  validator = Csvlint::Validator.new( @url ) 
  validator.encoding.should == encoding
end

Then(/^the content type should be "(.*?)"$/) do |content_type|
  validator = Csvlint::Validator.new( @url ) 
  validator.content_type.should == content_type
end
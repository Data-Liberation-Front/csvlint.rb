Given(/^the content type is "(.*?)"$/) do |arg1|
  @content_type = "text/csv"
end

Then(/^the "(.*?)" should be "(.*?)"$/) do |type, encoding|
  validator = Csvlint::Validator.new( @url ) 
  validator.send(type.to_sym).should == encoding
end

Then(/^the metadata content type should be "(.*?)"$/) do |content_type|
  validator = Csvlint::Validator.new( @url ) 
  validator.headers['content-type'].should == content_type
end

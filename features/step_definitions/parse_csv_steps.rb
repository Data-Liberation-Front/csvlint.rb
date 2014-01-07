Given(/^I have a CSV with the following content:$/) do |string|
  @csv = string
end

Given(/^it is stored at the url "(.*?)"$/) do |url|
  @url = url
  stub_request(:get, url).to_return(:status => 200, :body => @csv, :headers => {})
end

When(/^I ask if the CSV is valid$/) do
  @validator = Csvlint::Validator.new( @url ) 
  @valid = @validator.valid?
end

Then(/^I should get the value of true$/) do
  expect( @valid ).to be(true)
end

Then(/^I should get the value of false$/) do
  expect( @valid ).to be(false)
end

Given(/^I have a CSV with the following content:$/) do |string|
  @csv = string
end

Given(/^it is stored at the url "(.*?)"$/) do |url|
  stub_request(:get, url).to_return(:status => 200, :body => @csv, :headers => {})
end

When(/^I ask if the CSV is valid$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should get the value of "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given(/^I have stubbed stdin to contain "(.*?)"$/) do |file|
  expect(STDIN).to receive(:read).and_return(File.read(file))
end

Given(/^I have stubbed stdin to contain nothing$/) do
  expect(STDIN).to receive(:read).and_return(nil)
end

Then(/^nothing should be outputted to STDERR$/) do
  expect(STDERR).to_not receive(:puts)
end

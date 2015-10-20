Given(/^I have stubbed ARGF to contain "(.*?)"$/) do |file|
  expect(ARGF).to receive(:read).and_return(File.read(file))
end

Then(/^nothing should be outputted to STDERR$/) do
  expect(STDERR).to_not receive(:puts)
end

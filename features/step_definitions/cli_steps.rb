Given(/^I have stubbed ARGF to contain "(.*?)"$/) do |file|
  expect(ARGF).to receive(:read).and_return(File.read(file))
end

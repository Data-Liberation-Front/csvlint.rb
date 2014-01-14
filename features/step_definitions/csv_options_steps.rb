Given(/^I set the delimiter to "(.*?)"$/) do |delimiter|
  @csv_options ||= {}
  @csv_options["delimiter"] = delimiter
end

Given(/^I set quotechar to "(.*?)"$/) do |doublequote|
  @csv_options ||= {}
  @csv_options["quotechar"] = doublequote
end

Given(/^I set the line endings to windows$/) do
  @csv_options ||= {}
  @csv_options["lineterminator"] = "\r\n"
end
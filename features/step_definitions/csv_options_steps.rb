Given(/^I set the delimiter to "(.*?)"$/) do |delimiter|
  @csv_options ||= default_csv_options
  @csv_options["delimiter"] = delimiter
end

Given(/^I set quotechar to "(.*?)"$/) do |doublequote|
  @csv_options ||= default_csv_options
  @csv_options["quoteChar"] = doublequote
end

Given(/^I set the line endings to linefeed$/) do
  @csv_options ||= default_csv_options
  @csv_options["lineTerminator"] = "\r\n"
end
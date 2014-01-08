Given(/^I set the delimiter to "(.*?)"$/) do |delimiter|
  @csv_options ||= {}
  @csv_options["delimiter"] = delimiter
end

Given(/^I set doublequote to "(.*?)"$/) do |doublequote|
  @csv_options ||= {}
  @csv_options["doublequote"] = doublequote
end

Given(/^I set the line endings to "(.*?)"$/) do |arg1|
  @csv_options ||= {}
  @csv_options["lineterminator"] = "|"
end
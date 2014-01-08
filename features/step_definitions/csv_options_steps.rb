Given(/^I set the delimiter to "(.*?)"$/) do |delimiter|
  @csv_options ||= {}
  @csv_options[:delimiter] = delimiter
end

Given(/^I set doublequote to "(.*?)"$/) do |doublequote|
  @csv_options ||= {}
  @csv_options[:delimiter] = doublequote
end

$:.unshift File.join( File.dirname(__FILE__), "..", "..", "lib")

require 'simplecov'
require 'simplecov-rcov'
require 'rspec/expectations'
require 'csvlint'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

require 'spork'

Spork.each_run do
  require 'csvlint'
end
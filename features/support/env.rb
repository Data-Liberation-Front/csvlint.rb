$:.unshift File.join( File.dirname(__FILE__), "..", "..", "lib")

require 'simplecov'
require 'simplecov-rcov'
require 'rspec/expectations'
require 'csvlint'
require 'coveralls'
require 'pry'

Coveralls.wear_merged!

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

require 'spork'

Spork.each_run do
  require 'csvlint'
end

class CustomWorld
  def default_csv_options
    return {
      "lineTerminator" => "\n"
    }
  end
end

World do
  CustomWorld.new
end
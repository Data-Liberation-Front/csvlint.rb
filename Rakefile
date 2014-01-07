require "bundler/gem_tasks"

$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'
Coveralls::RakeTask.new

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

task :default => [:features, 'coveralls:push']
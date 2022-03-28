# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csvlint/version'

Gem::Specification.new do |spec|
  spec.name          = "csvlint"
  spec.version       = Csvlint::VERSION
  spec.authors       = ["pezholio"]
  spec.email         = ["pezholio@gmail.com"]
  spec.description   = %q{CSV Validator}
  spec.summary       = %q{CSV Validator}
  spec.homepage      = "https://github.com/theodi/csvlint.rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ['> 2.4', '< 3.2']

  spec.add_dependency "rainbow"
  spec.add_dependency "open_uri_redirections"
  spec.add_dependency "activesupport"
  spec.add_dependency "addressable"
  spec.add_dependency "typhoeus"
  spec.add_dependency "escape_utils"
  spec.add_dependency "uri_template"
  spec.add_dependency "thor"
  spec.add_dependency "rack"
  spec.add_dependency "net-http-persistent"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "cucumber", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "simplecov-rcov", "~> 0.2"
  spec.add_development_dependency "spork", "~> 0.9"
  spec.add_development_dependency "webmock", "~> 3.14"
  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_development_dependency "rspec-pride", "~> 3.2"
  spec.add_development_dependency "rspec-expectations", "~> 3.11"
  spec.add_development_dependency "rspec-pending_for", "~> 0.1"
  spec.add_development_dependency "coveralls", "~> 0.7"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "github_changelog_generator", "~> 1.16"
  spec.add_development_dependency "aruba", "~> 0.14"
  spec.add_development_dependency "rdf", "< 4.0"
  spec.add_development_dependency "rdf-turtle"

end

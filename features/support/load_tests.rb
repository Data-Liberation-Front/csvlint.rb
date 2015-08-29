require 'json'
require 'open-uri'
require 'uri'

BASE_URI = "http://w3c.github.io/csvw/tests/"

File.open(File.join(File.dirname(__FILE__), "..", "csvw_validation_tests.feature"), 'w') do |file|
	file.puts "# Auto-generated file based on standard validation CSVW tests from http://w3c.github.io/csvw/tests/manifest-validation.jsonld"
	file.puts ""

	manifest = JSON.parse( open("http://w3c.github.io/csvw/tests/manifest-validation.jsonld").read )

	file.puts "Feature: #{manifest["label"]}"
	file.puts ""
	
	manifest["entries"][0..9].each do |entry|
		action = URI.join(BASE_URI, entry["action"])
		metadata = nil
		file.puts "\t# #{entry["comment"]}"
		file.puts "\tScenario: #{entry["name"]}"
		file.puts "\t\tGiven I have a CSV with the following content:"
		file.puts "\t\t\"\"\""
		file.puts open(action).read
		file.puts "\t\t\"\"\""
		file.puts "\t\tAnd it is stored at the url \"#{action}\""
		if entry["option"] and entry["option"]["metadata"]
			metadata = URI.join(BASE_URI, entry["option"]["metadata"])
			file.puts "\t\tAnd I have metadata with the following content:"
			file.puts "\t\t\"\"\""
			file.puts open(metadata).read
			file.puts "\t\t\"\"\""
		end
		entry["implicit"].each do |implicit|
			uri = URI.join(BASE_URI, implicit)
			unless uri == metadata
				file.puts "\t\tAnd there is a file at \"#{uri}\" with the content:"
				file.puts "\t\t\"\"\""
				file.puts open(uri).read
				file.puts "\t\t\"\"\""
			end
		end if entry["implicit"]
		file.puts "\t\tWhen I ask if the CSV is valid"
    file.puts "\t\tThen I should get the value of true"
		file.puts "\t"
	end
end
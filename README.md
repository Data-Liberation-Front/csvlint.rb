[![Build Status](http://img.shields.io/travis/theodi/csvlint.rb.svg)](https://travis-ci.org/theodi/csvlint.rb)
[![Dependency Status](http://img.shields.io/gemnasium/theodi/csvlint.rb.svg)](https://gemnasium.com/theodi/csvlint.rb)
[![Coverage Status](http://img.shields.io/coveralls/theodi/csvlint.rb.svg)](https://coveralls.io/r/theodi/csvlint.rb)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://theodi.mit-license.org)
[![Badges](http://img.shields.io/:badges-5/5-ff6799.svg)](https://github.com/pikesley/badger)

# CSV Lint

A ruby gem to support validating CSV files to check their syntax and contents.

## Installation

Add this line to your application's Gemfile:

    gem 'csvlint'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csvlint

## Usage

Currently the gem supports retrieving a CSV accessible from a URL, File, or an IO-style object (e.g. StringIO)

	require 'csvlint'
	
	validator = Csvlint::Validator.new( "http://example.org/data.csv" )
	validator = Csvlint::Validator.new( File.new("/path/to/my/data.csv" )
	validator = Csvlint::Validator.new( StringIO.new( my_data_in_a_string ) )

When validating from a URL the range of errors and warnings is wider as the library will also check HTTP headers for 
best practices
	
	#invoke the validation	
	validator.validate
	
	#check validation status
	validator.valid?
	
	#access array of errors, each is an Csvlint::ErrorMessage object
	validator.errors
	
	#access array of warnings
	validator.warnings
	
	#get some information about the CSV file that was validated
	validator.encoding
	validator.content_type
	validator.extension
	
	#retrieve HTTP headers from request
	validator.headers


## Error Reporting

Errors and warnings returned by the validator are instances of `Csvlint::ErrorMessage`:

* `content` holds the contents of the row that generated the error or warning
* `row` holds the line number of the problem
* `type` has a symbol that indicates the type of error or warning being reported
* `category` has a symbol that indicates the category or error/warning: `:structure` (well-formedness issues), `:schema` (schema validation), `:context` (publishing metadata, e.g. content type)

The following types of error can be reported:

* `:wrong_content_type` -- content type is not `text/csv`
* `:ragged_rows` -- row has a different number of columns (than the first row in the file)
* `:blank_rows` -- completely empty row, e.g. blank line or a line where all column values are empty
* `:invalid_encoding` -- encoding error when parsing row, e.g. because of invalid characters 
* `:not_found` -- HTTP 404 error when retrieving the data
* `:quoting` -- problem with quoting, e.g. missing or stray quote, unclosed quoted field
* `:whitespace` -- a quoted column has leading or trailing whitespace

The following types of warning can be reported:

* `:no_encoding` -- the `Content-Type` header returned in the HTTP request does not have a `charset` parameter
* `:encoding` -- the character set is not UTF-8
* `:no_content_type` -- file is being served without a `Content-Type` header
* `:excel` -- no `Content-Type` header and the file extension is `.xls`
* `:check_options` -- CSV file appears to contain only a single column
* `:inconsistent_values` -- inconsistent values in the same column. Reported if <90% of values seem to have same data type (either numeric or alphanumeric including punctuation)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

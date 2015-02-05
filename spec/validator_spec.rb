require 'spec_helper'

describe Csvlint::Validator do
    
  before do
    stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :body => "")
  end
  
  context "csv dialect" do
    it "should provide sensible defaults for CSV parsing" do
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      opts = validator.instance_variable_get("@csv_options")
      opts.should include({
        :col_sep => ",",
        :row_sep => :auto,
        :quote_char => '"',
        :skip_blanks => false
      })
    end
    
    it "should map CSV DDF to correct values" do
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      opts = validator.dialect_to_csv_options( {
        "lineTerminator" => "\n",
        "delimiter" => "\t",
        "quoteChar" => "'"
      })
      opts.should include({
        :col_sep => "\t",
        :row_sep => "\n",
        :quote_char => "'",
        :skip_blanks => false
      })       
    end
    
  end
  
  context "when detecting headers" do
    it "should default to expecting a header" do
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      expect( validator.header? ).to eql(true)
    end
    
    it "should look in CSV options to detect header" do
      opts = {
        "header" => true
      }
      validator = Csvlint::Validator.new("http://example.com/example.csv", opts)
      expect( validator.header? ).to eql(true)
      opts = {
        "header" => false
      }
      validator = Csvlint::Validator.new("http://example.com/example.csv", opts)
      expect( validator.header? ).to eql(false)      
    end

    it "should look in content-type for header=absent" do
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/csv; header=absent"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      expect( validator.header? ).to eql(false)
      expect( validator.errors.size ).to eql(0)
    end

    it "should look in content-type for header=present" do
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/csv; header=present"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      expect( validator.header? ).to eql(true)
      expect( validator.errors.size ).to eql(0)
    end

    it "assume header present if not specified in content type" do
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/csv"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      expect( validator.header? ).to eql(true)
      expect( validator.errors.size ).to eql(0)
      expect( validator.info_messages.size ).to eql(1)
      expect( validator.info_messages.first.type).to eql(:assumed_header)
    end

    it "give undeclared header error if content type is wrong" do
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/html"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      expect( validator.header? ).to eql(true)
      expect( validator.errors.size ).to eql(2)
      expect( validator.errors[0].type).to eql(:wrong_content_type)
      expect( validator.errors[1].type).to eql(:undeclared_header)
      expect( validator.info_messages.size ).to eql(0)
    end

  end
  
  context "when validating headers" do
    it "should warn if column names aren't unique" do      
      data = StringIO.new( "minimum, minimum" )
      validator = Csvlint::Validator.new(data)
      expect( validator.validate_header(["minimum", "minimum"]) ).to eql(true)
      expect( validator.warnings.size ).to eql(1)
      expect( validator.warnings.first.type).to eql(:duplicate_column_name)
      expect( validator.warnings.first.category).to eql(:schema)
    end

    it "should warn if column names are blank" do
      data = StringIO.new( "minimum," )
      validator = Csvlint::Validator.new(data)
      
      expect( validator.validate_header(["minimum", ""]) ).to eql(true)
      expect( validator.warnings.size ).to eql(1)
      expect( validator.warnings.first.type).to eql(:empty_column_name)
      expect( validator.warnings.first.category).to eql(:schema)
    end
    
    it "should include info message about missing header when we have assumed a header" do
      data = StringIO.new( "1,2,3\r\n" )
      validator = Csvlint::Validator.new(data)
      
      expect( validator.valid? ).to eql(true)
      expect( validator.info_messages.size ).to eql(1)
      expect( validator.info_messages.first.type).to eql(:assumed_header)
      expect( validator.info_messages.first.category).to eql(:structure)
    end  

    it "should not include info message about missing header when we are told about the header" do
      data = StringIO.new( "1,2,3\r\n" )
      validator = Csvlint::Validator.new(data, "header"=>false)
      
      expect( validator.valid? ).to eql(true)
      expect( validator.info_messages.size ).to eql(0)
    end
    
    it "should be an error if we have assumed a header, there is no dialect and there's no content-type" do
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      expect( validator.valid? ).to eql(false)   
    end  
    
    it "should not be an error if we have assumed a header, there is no dialect and content-type doesn't declare header, as we assume header=present" do
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/csv"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      expect( validator.valid? ).to eql(true)   
    end

    it "should be valid if we have a dialect and the data is from the web" do
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/csv"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
      #header defaults to true in csv dialect, so this is valid
      validator = Csvlint::Validator.new("http://example.com/example.csv", {})
      expect( validator.valid? ).to eql(true)   

      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/csv"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))      
      validator = Csvlint::Validator.new("http://example.com/example.csv", {"header"=>true})
      expect( validator.valid? ).to eql(true) 
      
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/csv"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))      
      validator = Csvlint::Validator.new("http://example.com/example.csv", {"header"=>false})
      expect( validator.valid? ).to eql(true) 
    end
                        
  end
  
  context "build_formats" do
    
    {
      :string => "foo",
      :numeric => "1",
      :uri => "http://www.example.com",
      :dateTime_iso8601 => "2013-01-01T13:00:00Z",
      :date_db => "2013-01-01",
      :dateTime_hms => "13:00:00"
    }.each do |type, content|
      it "should return the format of #{type} correctly" do
        row = [content]
        
        validator = Csvlint::Validator.new("http://example.com/example.csv")
        validator.build_formats(row)
        formats = validator.instance_variable_get("@formats")
        
        formats[0].keys.first.should == type
      end
    end
    
    it "treats floats and ints the same" do
      row = ["12", "3.1476"]
      
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      validator.build_formats(row)
      formats = validator.instance_variable_get("@formats")
      
      formats[0].keys.first.should == :numeric
      formats[1].keys.first.should == :numeric
    end
  
    it "should ignore blank arrays" do
      row = []
    
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      validator.build_formats(row)
      formats = validator.instance_variable_get("@formats") 
      formats.should == []
    end
    
    it "should work correctly for single columns" do
      rows = [
          ["foo"],
          ["bar"],
          ["baz"]
        ]
        
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      
      rows.each_with_index do |row, i|
        validator.build_formats(row)
      end
      
      formats = validator.instance_variable_get("@formats")
      
      formats.should == [{:string => 3}]
    end
  
    it "should return formats correctly if a row is blank" do
      rows = [
          [],
          ["foo","1","$2345"]
        ]
      
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      
      rows.each_with_index do |row, i|
        validator.build_formats(row)
      end
      
      formats = validator.instance_variable_get("@formats") 
            
      formats.should == [
        {:string => 1},
        {:numeric => 1},
        {:string => 1},
      ]
    end
    
  end
  
  context "check_consistency" do
    
    it "should return a warning if columns have inconsistent values" do
      formats = [
          {:string => 3},
          {:string => 2, :numeric => 1},
          {:numeric => 3},
        ]
        
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      validator.instance_variable_set("@formats", formats)
      validator.check_consistency
          
      warnings = validator.instance_variable_get("@warnings") 
      warnings.delete_if { |h| h.type != :inconsistent_values }
      
      warnings.count.should == 1
    end
    
  end
  
  context "accessing metadata" do
   
    before :all do
      stub_request(:get, "http://example.com/crlf.csv").to_return(:status => 200, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','windows-line-endings.csv')))
    end
    
    it "can get line break symbol" do

      validator = Csvlint::Validator.new("http://example.com/crlf.csv")
      validator.line_breaks.should == "\r\n"
      
    end
    
  end
  
  it "should give access to the complete CSV data file" do
    stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, 
        :headers=>{"Content-Type" => "text/csv; header=present"}, 
        :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
    validator = Csvlint::Validator.new("http://example.com/example.csv")    
    expect( validator.valid? ).to eql(true)
    data = validator.data
    expect( data.count ).to eql 4
    expect( data[0] ).to eql ['Foo','Bar','Baz']
    expect( data[2] ).to eql ['3','2','1']
  end
  
  it "should limit number of lines read" do
    stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, 
    :headers=>{"Content-Type" => "text/csv; header=present"}, 
    :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
    validator = Csvlint::Validator.new("http://example.com/example.csv", nil, nil, limit_lines: 2)    
    expect( validator.valid? ).to eql(true)
    data = validator.data
    expect( data.count ).to eql 2    
    expect( data[0] ).to eql ['Foo','Bar','Baz']
  end
  
  it "should follow redirects to SSL" do
    stub_request(:get, "http://example.com/redirect").to_return(:status => 301, :headers=>{"Location" => "https://example.com/example.csv"})
    stub_request(:get, "https://example.com/example.csv").to_return(:status => 200, 
        :headers=>{"Content-Type" => "text/csv; header=present"}, 
        :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))

    validator = Csvlint::Validator.new("http://example.com/redirect")    
    expect( validator.valid? ).to eql(true)
  end
end
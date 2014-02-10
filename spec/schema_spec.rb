require 'spec_helper'

describe Csvlint::Schema do
  
  it "should validate against the schema" do
    field = Csvlint::Field.new("test", { "required" => true } )
    field2 = Csvlint::Field.new("test", { "minLength" => 3 } )
    schema = Csvlint::Schema.new("http://example.org", [field, field2] )
    
    expect( schema.validate_row( ["", "x"] ) ).to eql(false)
    expect( schema.validate_row( ["abc", "1234"] ) ).to eql(true)
      
  end
  
  context "when parsing JSON Tables" do
    
    before(:each) do 
      @example=<<-EOL
      {
          "fields": [
              { "name": "ID", "constraints": { "required": true } },
              { "name": "Price", "constraints": { "required": true, "minLength": 1 } },
              { "name": "Postcode", "constraints": { "required": true, "pattern": "[A-Z]{1,2}[0-9][0-9A-Z]? ?[0-9][A-Z]{2}" } }
          ]
      }
  EOL
      stub_request(:get, "http://example.com/example.json").to_return(:status => 200, :body => @example)
    end
    
    it "should create a schema from a pre-parsed JSON table" do
      json = JSON.parse( @example )
      schema = Csvlint::Schema.from_json_table("http://example.org", json)
      
      expect( schema.uri ).to eql("http://example.org")
      expect( schema.fields.length ).to eql(3)
      expect( schema.fields[0].name ).to eql("ID")
      expect( schema.fields[0].constraints["required"] ).to eql(true)
    end
    
    it "should create a schema from a JSON Table URL" do
      schema = Csvlint::Schema.load_from_json_table("http://example.com/example.json")
      expect( schema.uri ).to eql("http://example.com/example.json")
      expect( schema.fields.length ).to eql(3)
      expect( schema.fields[0].name ).to eql("ID")
      expect( schema.fields[0].constraints["required"] ).to eql(true)
      
    end
  end  
  
end
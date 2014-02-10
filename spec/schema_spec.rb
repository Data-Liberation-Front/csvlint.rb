require 'spec_helper'

describe Csvlint::Schema do
  
  it "should validate against the schema" do
    field = Csvlint::Field.new("test", { :required => true } )
    field2 = Csvlint::Field.new("test", { :minLength => 3 } )
    schema = Csvlint::Schema.new("http://example.org", [field, field2] )
    
    expect( schema.validate_row( ["", "x"] ) ).to eql(false)
    expect( schema.validate_row( ["abc", "1234"] ) ).to eql(true)
      
  end
  
end
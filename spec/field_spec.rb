require 'spec_helper'

describe Csvlint::Field do
  
  it "should validate required fields" do
    field = Csvlint::Field.new("test", { "required" => true } )
    expect( field.validate_column( nil ) ).to be(false)  
    expect( field.errors.first.category ).to be(:schema)
    expect( field.validate_column( "" ) ).to be(false)
    expect( field.validate_column( "data" ) ).to be(true)
  end
  
  it "should validate minimum length" do
    field = Csvlint::Field.new("test", { "minLength" => 3 } )
    expect( field.validate_column( nil ) ).to be(false)
    expect( field.validate_column( "" ) ).to be(false)    
    expect( field.validate_column( "ab" ) ).to be(false)
    expect( field.validate_column( "abc" ) ).to be(true)
    expect( field.validate_column( "abcd" ) ).to be(true)    
  end
  
  it "should validate maximum length" do
    field = Csvlint::Field.new("test", { "maxLength" => 3 } )
    expect( field.validate_column( nil ) ).to be(true)
    expect( field.validate_column( "" ) ).to be(true)    
    expect( field.validate_column( "ab" ) ).to be(true)
    expect( field.validate_column( "abc" ) ).to be(true)
    expect( field.validate_column( "abcd" ) ).to be(false)
  end
  
  it "should validate against regex" do
    field = Csvlint::Field.new("test", { "pattern" => "\{[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}\}"} )
    expect( field.validate_column( "abc") ).to be(false)
    expect( field.validate_column( "{3B0DA29C-C89A-4FAA-918A-0000074FA0E0}") ).to be(true)  
  end
  
  it "should apply combinations of constraints" do
    field = Csvlint::Field.new("test", { "required"=>true, "pattern" => "\{[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}\}"} )
    expect( field.validate_column( "abc") ).to be(false)
    expect( field.validate_column( nil ) ).to be(false)
    expect( field.validate_column( "{3B0DA29C-C89A-4FAA-918A-0000074FA0E0}") ).to be(true)  
    
  end

  it "should enforce uniqueness for a column" do
    field = Csvlint::Field.new("test", { "unique" => true } )
    expect( field.validate_column( "abc") ).to be(true)
    expect( field.validate_column( "abc") ).to be(false)
    expect( field.errors.first.category ).to be(:schema)
    expect( field.errors.first.type ).to be(:unique)
  end
  
end
require 'spec_helper'

describe Csvlint::Validator do
    
  before do
    stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :body => "")
  end
  
  context "build_formats" do
  
    it "should return the format of each column correctly" do    
      row = ["foo","1","$2345"]
    
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      validator.build_formats(row, 1)
      formats = validator.instance_variable_get("@formats") 
      formats[0].first.should == :alpha
      formats[1].first.should == :numeric
      formats[2].first.should == :unknown
    end
  
    it "should ignore blank arrays" do
      row = []
    
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      validator.build_formats(row, 1)
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
        validator.build_formats(row, i)
      end
      
      formats = validator.instance_variable_get("@formats")
      
      formats.should == [
        [:alpha, :alpha, :alpha],
      ]
    end
  
    it "should return formats correctly if a row is blank" do
      rows = [
          [],
          ["foo","1","$2345"]
        ]
      
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      
      rows.each_with_index do |row, i|
        validator.build_formats(row, i)
      end
      
      formats = validator.instance_variable_get("@formats") 
            
      formats.should == [
        [:alpha],
        [:numeric],
        [:unknown]
      ]
    end
    
  end
  
  context "check_consistency" do
    
    it "should return a warning if columns have inconsistent values" do
      formats = [
          [:alpha, :alpha, :alpha],
          [:alpha, :numeric, :alpha],
          [:unknown, :unknown, :unknown],
        ]
        
      validator = Csvlint::Validator.new("http://example.com/example.csv")
      validator.instance_variable_set("@formats", formats)
      validator.check_consistency(3)
          
      warnings = validator.instance_variable_get("@warnings") 
      warnings.delete_if { |h| h[:type] != :inconsistent_values }
      
      warnings.count.should == 1
    end
    
  end
  
end
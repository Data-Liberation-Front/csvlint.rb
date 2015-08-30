require 'spec_helper'

describe Csvlint::CsvwColumn do

  it "shouldn't generate errors for string values" do
    column = Csvlint::CsvwColumn.new(1, "foo")
    valid = column.validate("bar", 2)
    expect(valid).to eq(true)
  end

  it "should generate errors for string values that aren't long enough" do
    column = Csvlint::CsvwColumn.new(1, "foo", datatype: { "base" => "xsd:string", "minLength" => 4 })
    valid = column.validate("bar", 2)
    expect(valid).to eq(false)
    expect(column.errors.length).to eq(1)
  end

  it "shouldn't generate errors for string values that are long enough" do
    column = Csvlint::CsvwColumn.new(1, "foo", datatype: { "base" => "xsd:string", "minLength" => 4 })
    valid = column.validate("barn", 2)
    expect(valid).to eq(true)
    expect(column.errors.length).to eq(0)
  end

  context "when parsing CSVW column descriptions" do
    it "should provide appropriate default values" do
      @desc=<<-EOL
      {
        "name": "countryCode"
      }
      EOL
      json = JSON.parse( @desc )
      column = Csvlint::CsvwColumn.from_json(1, json)

      expect(column).to be_a(Csvlint::CsvwColumn)
      expect(column.number).to eq(1)
      expect(column.name).to eq("countryCode")
      expect(column.about_url).to eq(nil)
      expect(column.datatype).to eq("xsd:string")
      expect(column.default).to eq("")
      expect(column.lang).to eq("und")
      expect(column.null).to eq("")
      expect(column.ordered).to eq(false)
      expect(column.property_url).to eq(nil)
      expect(column.required).to eq(false)
      expect(column.separator).to eq(nil)
      expect(column.source_number).to eq(1)
      expect(column.suppress_output).to eq(false)
      expect(column.text_direction).to eq(:inherit)
      expect(column.titles).to eq({})
      expect(column.value_url).to eq(nil)
      expect(column.virtual).to eq(false)
      expect(column.annotations).to eql({})
    end

    it "should override default values" do
      @desc=<<-EOL
      {
        "name": "countryCode",
        "titles": "countryCode",
        "propertyUrl": "http://www.geonames.org/ontology{#_name}"
      }
      EOL
      json = JSON.parse( @desc )
      column = Csvlint::CsvwColumn.from_json(2, json)

      expect(column).to be_a(Csvlint::CsvwColumn)
      expect(column.number).to eq(2)
      expect(column.name).to eq("countryCode")
      expect(column.about_url).to eq(nil)
      expect(column.datatype).to eq("xsd:string")
      expect(column.default).to eq("")
      expect(column.lang).to eq("und")
      expect(column.null).to eq("")
      expect(column.ordered).to eq(false)
      expect(column.property_url).to eq("http://www.geonames.org/ontology{#_name}")
      expect(column.required).to eq(false)
      expect(column.separator).to eq(nil)
      expect(column.source_number).to eq(2)
      expect(column.suppress_output).to eq(false)
      expect(column.text_direction).to eq(:inherit)
      expect(column.titles).to eql({ "und" => [ "countryCode" ]})
      expect(column.value_url).to eq(nil)
      expect(column.virtual).to eq(false)
      expect(column.annotations).to eql({})
    end

    it "should include the datatype" do
      @desc=<<-EOL
      { "name": "Id", "required": true, "datatype": { "base": "string", "minLength": 3 } }
      EOL
      json = JSON.parse(@desc)
      column = Csvlint::CsvwColumn.from_json(1, json)
      expect(column.name).to eq("Id")
      expect(column.required).to eq(true)
      expect(column.datatype).to eql({ "base" => "xsd:string", "minLength" => 3 })
    end

    it "should generate warnings for invalid null values" do
      @desc=<<-EOL
      {
        "name": "countryCode",
        "null": true
      }
      EOL
      json = JSON.parse( @desc )
      column = Csvlint::CsvwColumn.from_json(1, json)
      expect(column.warnings.length).to eq(1)
      expect(column.warnings[0].type).to eq(:invalid_value)
    end
  end
end

require 'spec_helper'

describe Csvlint::CsvwNumberFormat do

  it "should correctly parse #,##0.##" do
    format = Csvlint::CsvwNumberFormat.new("#,##0.##")
    expect(format.pattern).to eq("#,##0.##")
    expect(format.prefix).to eq("")
    expect(format.numeric_part).to eq("#,##0.##")
    expect(format.suffix).to eq("")
    expect(format.grouping_separator).to eq(",")
    expect(format.decimal_separator).to eq(".")
    expect(format.primary_grouping_size).to eq(3)
    expect(format.secondary_grouping_size).to eq(3)
    expect(format.fractional_grouping_size).to eq(0)
  end

  it "should correctly parse ###0.#####" do
    format = Csvlint::CsvwNumberFormat.new("###0.#####")
    expect(format.primary_grouping_size).to eq(0)
    expect(format.secondary_grouping_size).to eq(0)
    expect(format.fractional_grouping_size).to eq(0)
  end

  it "should correctly parse ###0.0000#" do
    format = Csvlint::CsvwNumberFormat.new("###0.0000#")
    expect(format.primary_grouping_size).to eq(0)
    expect(format.secondary_grouping_size).to eq(0)
    expect(format.fractional_grouping_size).to eq(0)
  end

  it "should correctly parse #,##,###,####" do
    format = Csvlint::CsvwNumberFormat.new("#,##,###,####")
    expect(format.primary_grouping_size).to eq(4)
    expect(format.secondary_grouping_size).to eq(3)
    expect(format.fractional_grouping_size).to eq(0)
  end

  it "should correctly parse #,##0.###,#" do
    format = Csvlint::CsvwNumberFormat.new("#,##0.###,#")
    expect(format.primary_grouping_size).to eq(3)
    expect(format.secondary_grouping_size).to eq(3)
    expect(format.fractional_grouping_size).to eq(3)
  end

  it "should match numbers that match ##0 correctly" do
    format = Csvlint::CsvwNumberFormat.new("##0")
    expect(format.match("1")).to eq(true)
    expect(format.match("12")).to eq(true)
    expect(format.match("123")).to eq(true)
    expect(format.match("1234")).to eq(true)
    expect(format.match("1,234")).to eq(false)
    expect(format.match("123.4")).to eq(false)
  end

  it "should match numbers that match #,#00 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#,#00")
    expect(format.match("1")).to eq(false)
    expect(format.match("12")).to eq(true)
    expect(format.match("123")).to eq(true)
    expect(format.match("1234")).to eq(false)
    expect(format.match("1,234")).to eq(true)
    expect(format.match("1,234,568")).to eq(true)
    expect(format.match("12,34,568")).to eq(false)
    expect(format.match("12,34")).to eq(false)
    expect(format.match("123.4")).to eq(false)
  end

  it "should match numbers that match #,000 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#,000")
    expect(format.match("1")).to eq(false)
    expect(format.match("12")).to eq(false)
    expect(format.match("123")).to eq(true)
    expect(format.match("1234")).to eq(false)
    expect(format.match("1,234")).to eq(true)
    expect(format.match("1,234,568")).to eq(true)
    expect(format.match("12,34,568")).to eq(false)
    expect(format.match("12,34")).to eq(false)
    expect(format.match("123.4")).to eq(false)
  end

  it "should match numbers that match #,##,#00 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#,##,#00")
    expect(format.match("1")).to eq(false)
    expect(format.match("12")).to eq(true)
    expect(format.match("123")).to eq(true)
    expect(format.match("1234")).to eq(false)
    expect(format.match("1,234")).to eq(true)
    expect(format.match("1,234,568")).to eq(false)
    expect(format.match("12,34,568")).to eq(true)
    expect(format.match("12,34")).to eq(false)
    expect(format.match("123.4")).to eq(false)
  end

  it "should match numbers that match #0.# correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.#")
    expect(format.match("1")).to eq(true)
    expect(format.match("12")).to eq(true)
    expect(format.match("12.3")).to eq(true)
    expect(format.match("12.34")).to eq(false)
    expect(format.match("1234.5")).to eq(true)
    expect(format.match("1,234.5")).to eq(false)
  end

  it "should match numbers that match #0.0 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.0")
    expect(format.match("1")).to eq(false)
    expect(format.match("12")).to eq(false)
    expect(format.match("12.3")).to eq(true)
    expect(format.match("12.34")).to eq(false)
    expect(format.match("1234.5")).to eq(true)
    expect(format.match("1,234.5")).to eq(false)
  end

  it "should match numbers that match #0.0# correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.0#")
    expect(format.match("1")).to eq(false)
    expect(format.match("12")).to eq(false)
    expect(format.match("12.3")).to eq(true)
    expect(format.match("12.34")).to eq(true)
    expect(format.match("12.345")).to eq(false)
  end

  it "should match numbers that match #0.0#,# correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.0#,#")
    expect(format.match("1")).to eq(false)
    expect(format.match("12.3")).to eq(true)
    expect(format.match("12.34")).to eq(true)
    expect(format.match("12.345")).to eq(false)
    expect(format.match("12.34,5")).to eq(true)
    expect(format.match("12.34,56")).to eq(true)
    expect(format.match("12.34,567")).to eq(false)
    expect(format.match("12.34,56,7")).to eq(true)
  end

end

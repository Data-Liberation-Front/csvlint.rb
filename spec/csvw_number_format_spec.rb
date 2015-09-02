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

  it "should correctly parse #0.###E#0" do
    format = Csvlint::CsvwNumberFormat.new("#0.###E#0")
    expect(format.prefix).to eq("")
    expect(format.numeric_part).to eq("#0.###E#0")
    expect(format.suffix).to eq("")
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

  it "should match numbers that match #0.###E#0 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.###E#0")
    expect(format.match("1")).to eq(false)
    expect(format.match("12.3")).to eq(false)
    expect(format.match("12.34")).to eq(false)
    expect(format.match("12.3E4")).to eq(true)
    expect(format.match("12.3E45")).to eq(true)
    expect(format.match("12.34E5")).to eq(true)
  end

  it "should parse numbers that match ##0 correctly" do
    format = Csvlint::CsvwNumberFormat.new("##0")
    expect(format.parse("1")).to eql(1)
    expect(format.parse("12")).to eql(12)
    expect(format.parse("123")).to eql(123)
    expect(format.parse("1234")).to eql(1234)
    expect(format.parse("1,234")).to eq(nil)
    expect(format.parse("123.4")).to eq(nil)
  end

  it "should parse numbers that match #,#00 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#,#00")
    expect(format.parse("1")).to eq(nil)
    expect(format.parse("12")).to eql(12)
    expect(format.parse("123")).to eql(123)
    expect(format.parse("1234")).to eq(nil)
    expect(format.parse("1,234")).to eql(1234)
    expect(format.parse("1,234,568")).to eql(1234568)
    expect(format.parse("12,34,568")).to eq(nil)
    expect(format.parse("12,34")).to eq(nil)
    expect(format.parse("123.4")).to eq(nil)
  end

  it "should parse numbers that match #,000 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#,000")
    expect(format.parse("1")).to eq(nil)
    expect(format.parse("12")).to eq(nil)
    expect(format.parse("123")).to eql(123)
    expect(format.parse("1234")).to eq(nil)
    expect(format.parse("1,234")).to eql(1234)
    expect(format.parse("1,234,568")).to eql(1234568)
    expect(format.parse("12,34,568")).to eq(nil)
    expect(format.parse("12,34")).to eq(nil)
    expect(format.parse("123.4")).to eq(nil)
  end

  it "should parse numbers that match #,##,#00 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#,##,#00")
    expect(format.parse("1")).to eq(nil)
    expect(format.parse("12")).to eql(12)
    expect(format.parse("123")).to eql(123)
    expect(format.parse("1234")).to eq(nil)
    expect(format.parse("1,234")).to eql(1234)
    expect(format.parse("1,234,568")).to eq(nil)
    expect(format.parse("12,34,568")).to eql(1234568)
    expect(format.parse("12,34")).to eq(nil)
    expect(format.parse("123.4")).to eq(nil)
  end

  it "should parse numbers that match #0.# correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.#")
    expect(format.parse("1")).to eql(1.0)
    expect(format.parse("12")).to eql(12.0)
    expect(format.parse("12.3")).to eql(12.3)
    expect(format.parse("12.34")).to eq(nil)
    expect(format.parse("1234.5")).to eql(1234.5)
    expect(format.parse("1,234.5")).to eq(nil)
  end

  it "should parse numbers that match #0.0 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.0")
    expect(format.parse("1")).to eq(nil)
    expect(format.parse("12")).to eq(nil)
    expect(format.parse("12.3")).to eql(12.3)
    expect(format.parse("12.34")).to eq(nil)
    expect(format.parse("1234.5")).to eql(1234.5)
    expect(format.parse("1,234.5")).to eq(nil)
  end

  it "should parse numbers that match #0.0# correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.0#")
    expect(format.parse("1")).to eq(nil)
    expect(format.parse("12")).to eq(nil)
    expect(format.parse("12.3")).to eql(12.3)
    expect(format.parse("12.34")).to eql(12.34)
    expect(format.parse("12.345")).to eq(nil)
  end

  it "should parse numbers that match #0.0#,# correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.0#,#")
    expect(format.parse("1")).to eq(nil)
    expect(format.parse("12.3")).to eql(12.3)
    expect(format.parse("12.34")).to eql(12.34)
    expect(format.parse("12.345")).to eq(nil)
    expect(format.parse("12.34,5")).to eql(12.345)
    expect(format.parse("12.34,56")).to eql(12.3456)
    expect(format.parse("12.34,567")).to eq(nil)
    expect(format.parse("12.34,56,7")).to eql(12.34567)
  end

  it "should parse numbers that match #0.###E#0 correctly" do
    format = Csvlint::CsvwNumberFormat.new("#0.###E#0")
    expect(format.parse("1")).to eq(nil)
    expect(format.parse("12.3")).to eq(nil)
    expect(format.parse("12.34")).to eq(nil)
    expect(format.parse("12.3E4")).to eql(12.3E4)
    expect(format.parse("12.3E45")).to eql(12.3E45)
    expect(format.parse("12.34E5")).to eql(12.34E5)
  end

  it "should parse numbers normally when there is no pattern" do
    format = Csvlint::CsvwNumberFormat.new()
    expect(format.parse("1")).to eql(1)
    expect(format.parse("-1")).to eql(-1)
    expect(format.parse("12.3")).to eql(12.3)
    expect(format.parse("12.34")).to eql(12.34)
    expect(format.parse("12.3E4")).to eql(12.3E4)
    expect(format.parse("12.3E45")).to eql(12.3E45)
    expect(format.parse("12.34E5")).to eql(12.34E5)
    expect(format.parse("12.34e5")).to eql(12.34E5)
    expect(format.parse("-12.34")).to eql(-12.34)
    expect(format.parse("1,234")).to eq(nil)
    expect(format.parse("NaN").nan?).to eq(true)
    expect(format.parse("INF")).to eql(Float::INFINITY)
    expect(format.parse("-INF")).to eql(-Float::INFINITY)
    expect(format.parse("123456.789F10")).to eq(nil)
  end

  it "should parse numbers including grouping separators when they are specified" do
    format = Csvlint::CsvwNumberFormat.new(nil, ",")
    expect(format.parse("1")).to eql(1)
    expect(format.parse("12.3")).to eql(12.3)
    expect(format.parse("12.34")).to eql(12.34)
    expect(format.parse("12.3E4")).to eql(12.3E4)
    expect(format.parse("12.3E45")).to eql(12.3E45)
    expect(format.parse("12.34E5")).to eql(12.34E5)
    expect(format.parse("1,234")).to eql(1234)
    expect(format.parse("1,234,567")).to eql(1234567)
    expect(format.parse("1,,234")).to eq(nil)
    expect(format.parse("NaN").nan?).to eq(true)
    expect(format.parse("INF")).to eql(Float::INFINITY)
    expect(format.parse("-INF")).to eql(-Float::INFINITY)
  end

end

require 'spec_helper'
require 'thor_helper'
require 'csvlint/cli'

describe Csvlint::Cli do

  before :each do
    @subject = Csvlint::Cli.new
  end

  context "with a valid file" do
    before :each do
      file = File.new(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv'))
      @output = capture(:stdout) { @subject.validate(file) }
    end

    it "validates a single csv from a file" do
      expect(@output).to match /valid.csv is VALID/
    end

    it "outputs dots for each line" do
      green_dot = '.'.green

      expect(@output.lines.first).to eq("#{green_dot}#{green_dot}#{green_dot}\r\n")
    end
  end

  context "with a valid URL" do
    before :each do
      stub_request(:get, "http://example.com/.well-known/csvm").to_return(:status => 404)
      stub_request(:get, "http://example.com/example.csv-metadata.json").to_return(:status => 404)
      stub_request(:get, "http://example.com/csv-metadata.json").to_return(:status => 404)
      stub_request(:get, "http://example.com/example.csv").to_return(:status => 200, :headers=>{"Content-Type" => "text/csv"}, :body => File.read(File.join(File.dirname(__FILE__),'..','features','fixtures','valid.csv')))
      @output = capture(:stdout) { @subject.validate("http://example.com/example.csv") }
    end

    it "validates a single csv from a file" do
      expect(@output).to match /http:\/\/example\.com\/example\.csv is VALID/
    end

    it "outputs dots for each line" do
      green_dot = '.'.green

      expect(@output.lines.first).to eq("#{green_dot}#{green_dot}#{green_dot}\r\n")
    end
  end

end

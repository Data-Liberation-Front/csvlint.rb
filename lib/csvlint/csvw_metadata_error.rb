module Csvlint

  class CsvwMetadataError < StandardError

    attr_reader :path

    def initialize(path=nil)
      @path = path
    end

  end

end

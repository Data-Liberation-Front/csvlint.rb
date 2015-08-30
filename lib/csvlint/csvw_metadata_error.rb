module Csvlint

  class CsvwMetadataError < StandardError

    attr_reader :path

    def initialize(path)
      @path = path
    end

  end

end

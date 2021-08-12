module Csvlint
  module FileUrl

    # Convert a path to an absolute file:// uri
    def FileUrl.url(path)
      File.expand_path(path).gsub(/^\/*/, "file:///")
      #URI.encode(File.expand_path(path).gsub(/^\/*/, "file:///"))
    end

    # Convert an file:// uri to a File
    def FileUrl.file(uri)
      if uri.start_with?("file:")
        File.new(uri.gsub(/^file:\/\//, ""))
      else
        uri
      end
    end
  end
end

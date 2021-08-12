module Csvlint
  module FileUrl

    # Convert a path to an absolute file:// uri
    def FileUrl.url(path)
      File.expand_path(path).gsub(/^\/*/, "file:///")
      #URI.encode(File.expand_path(path).gsub(/^\/*/, "file:///"))
    end

    # Convert an file:// uri to a plain path
    def FileUrl.path(uri)
      uri.gsub(/^file:\/\//, "")
    end
  end
end

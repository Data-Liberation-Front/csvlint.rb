module Csvlint
  class WrappedIO
    def initialize(io)
      @io = io
      @line = ""
    end
  
    def gets(delim)
      @line = "" if @new_line
      s = @io.gets(delim)
      if s != nil
        @line << s 
      end
      return s
    end
  
    def eof?
      @io.eof?
    end
  
    def finished
      @new_line = true
    end
  
    def line
      @line
    end
  end
end
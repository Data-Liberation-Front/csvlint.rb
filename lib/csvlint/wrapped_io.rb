module Csvlint
  class WrappedIO
    def initialize(io)
      @io = io
      @line = ""
    end
  
    def gets(*args)
      if args.count == 1 && args[0].is_a?(String)
        delim = args[0]
        @line = "" if @new_line
        s = @io.gets(delim)
        if s != nil
          @line << s 
        end
        return s
      else
        @io.gets(*args)
      end
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
    
    def method_missing(method, *args)
      @io.send(method, *args)
    end
    
  end
end
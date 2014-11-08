module Csvlint
  class WrappedIO < SimpleDelegator
    attr_reader :line

    def reset_line
      @line = ''
    end

    def gets(*args)
      if args.size == 1 && args[0].is_a?(String)
        s = __getobj__.gets(args[0])
        if s
          @line << s
        end
        s
      else
        __getobj__.gets(*args)
      end
    end
  end
end

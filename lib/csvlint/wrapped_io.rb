module Csvlint
  class WrappedIO < SimpleDelegator
    attr_reader :line

    def reset_line
      @line = ''
    end

    def gets(*args)
      if args.size == 1 && args[0].is_a?(String)
        s = super
        if s
          @line << s
        end
        s
      else
        super
      end
    end
  end
end

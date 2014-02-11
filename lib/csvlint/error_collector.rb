module Csvlint
  
  module ErrorCollector
    
    attr_reader :errors, :warnings
    
    def build_message(type, category, row, column, content)
      Csvlint::ErrorMessage.new({
                                  :type => type,
                                  :category => category,
                                  :row => row,
                                  :column => column,
                                  :content => content
                                })
    end
    
    def build_errors(type, category = nil, row = nil, column = nil, content = nil)
      @errors << build_message(type, category, row, column, content)
    end
    
    def build_warnings(type, category = nil, row = nil, column = nil, content = nil)
      @warnings << build_message(type, category, row, column, content)
    end
    
    def valid?
      errors.empty?
    end
    
    def reset
      @errors = []
      @warnings = []
    end
    
  end
end
require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'time'

module Dry
  module Types
    module Coercions
      module Symbol
        def self.to_symbol(input)
          if input.respond_to?(:to_sym)
            input.to_sym
          else
            input
          end
        end
      end
    end
  end
end

require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'time'

module Dry
  module Types
    module Coercions
      module JSON
        extend Coercions

        # @param [#to_d, Object] input
        # @return [BigDecimal,nil]
        def self.to_decimal(input, &block)
          if input.is_a?(::Float)
            input.to_d
          else
            BigDecimal(input)
          end
        rescue ArgumentError, TypeError => error
          if block_given?
            yield
          else
            raise CoercionError.new("#{input} cannot be coerced to decimal")
          end
        end
      end
    end
  end
end

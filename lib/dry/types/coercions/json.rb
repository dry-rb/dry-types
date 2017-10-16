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
        def self.to_decimal(input)
          return if input.nil?
          input.to_d unless empty_str?(input)
        end
      end
    end
  end
end

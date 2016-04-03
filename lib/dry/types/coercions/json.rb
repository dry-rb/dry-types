require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'time'

module Dry
  module Types
    module Coercions
      module JSON
        extend Coercions

        def self.to_decimal(input)
          if input.is_a?(String) && input == ''
            nil
          else
            input.to_d
          end
        end
      end
    end
  end
end

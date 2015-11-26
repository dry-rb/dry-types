require 'date'
require 'bigdecimal'
require 'bigdecimal/util'

module Dry
  module Data
    module Coercions
      module Form
        TRUE_VALUES  = %w[1 on  t true  y yes].freeze
        FALSE_VALUES = %w[0 off f false n no].freeze
        BOOLEAN_MAP  = ::Hash[ TRUE_VALUES.product([true]) + FALSE_VALUES.product([false]) ].freeze

        def self.to_bool(input)
          BOOLEAN_MAP.fetch(input)
        end

        def self.to_int(input)
          if input == ''
            nil
          else
            input.to_i
          end
        end

        def self.to_float(input)
          if input == ''
            nil
          else
            input.to_f
          end
        end

        def self.to_decimal(input)
          if input == ''
            nil
          else
            BigDecimal(input)
          end
        end
      end
    end
  end
end

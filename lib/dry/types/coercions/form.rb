require 'bigdecimal'
require 'bigdecimal/util'

module Dry
  module Types
    module Coercions
      module Form
        TRUE_VALUES = %w[1 on  t true  y yes].freeze
        FALSE_VALUES = %w[0 off f false n no].freeze
        BOOLEAN_MAP = ::Hash[TRUE_VALUES.product([true]) + FALSE_VALUES.product([false])].freeze

        extend Coercions

        def self.to_true(input)
          BOOLEAN_MAP.fetch(input, input)
        end

        def self.to_false(input)
          BOOLEAN_MAP.fetch(input, input)
        end

        def self.to_int(input)
          return if empty_str?(input)

          result = input.to_i

          if result === 0 && !input.eql?('0')
            input
          else
            result
          end
        end

        def self.to_float(input)
          return if empty_str?(input)

          result = input.to_f

          if result.eql?(0.0) && (!input.eql?('0') && !input.eql?('0.0'))
            input
          else
            result
          end
        end

        def self.to_decimal(input)
          result = to_float(input)

          if result.instance_of?(Float)
            result.to_d
          else
            result
          end
        end
      end
    end
  end
end

require 'bigdecimal'
require 'bigdecimal/util'

module Dry
  module Types
    module Coercions
      module Form
        TRUE_VALUES = %w[1 on On ON t true True TRUE T y yes Yes YES Y].freeze
        FALSE_VALUES = %w[0 off Off OFF f false False FALSE F n no No NO N].freeze
        BOOLEAN_MAP = ::Hash[TRUE_VALUES.product([true]) + FALSE_VALUES.product([false])].freeze

        extend Coercions

        # @param [String, Object] input
        # @return [Boolean,Object]
        # @see TRUE_VALUES
        # @see FALSE_VALUES
        def self.to_true(input)
          BOOLEAN_MAP.fetch(input.to_s, input)
        end

        # @param [String, Object] input
        # @return [Boolean,Object]
        # @see TRUE_VALUES
        # @see FALSE_VALUES
        def self.to_false(input)
          BOOLEAN_MAP.fetch(input.to_s, input)
        end

        # @param [#to_int, #to_i, Object] input
        # @return [Integer, nil, Object]
        def self.to_int(input)
          if empty_str?(input)
            nil
          else
            Integer(input)
          end
        rescue ArgumentError, TypeError
          input
        end

        # @param [#to_f, Object] input
        # @return [Float, nil, Object]
        def self.to_float(input)
          if empty_str?(input)
            nil
          else
            Float(input)
          end
        rescue ArgumentError, TypeError
          input
        end

        # @param [#to_d, Object] input
        # @return [BigDecimal, nil, Object]
        def self.to_decimal(input)
          result = to_float(input)

          if result.instance_of?(Float)
            input.to_d
          else
            result
          end
        end

        # @param [Array, String, Object] input
        # @return [Array, Object]
        def self.to_ary(input)
          empty_str?(input) ? [] : input
        end

        # @param [Hash, String, Object] input
        # @return [Hash, Object]
        def self.to_hash(input)
          empty_str?(input) ? {} : input
        end
      end
    end
  end
end

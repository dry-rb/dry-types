module Dry
  module Types
    extend Dry::Configurable

    # @!attribute [r] namespace
    #   @return [Container{String => Definition}]
    setting :namespace, self

    class SchemaError < TypeError
      # @param [String,Symbol] key
      # @param [Object] value
      # @param [String, #to_s] result
      def initialize(key, value, result)
        super("#{value.inspect} (#{value.class}) has invalid type for :#{key} violates constraints (#{result} failed)")
      end
    end

    SchemaKeyError = Class.new(KeyError)
    private_constant(:SchemaKeyError)

    class MissingKeyError < SchemaKeyError
      # @param [String,Symbol] key
      def initialize(key)
        super(":#{key} is missing in Hash input")
      end
    end

    class UnknownKeysError < SchemaKeyError
      # @param [<String, Symbol>] keys
      def initialize(*keys)
        super("unexpected keys #{keys.inspect} in Hash input")
      end
    end

    class ConstraintError < TypeError
      # @return [String, #to_s]
      attr_reader :result
      # @return [Object]
      attr_reader :input

      # @param [String, #to_s] result
      # @param [Object] input
      def initialize(result, input)
        @result = result
        @input = input

        if result.is_a?(String)
          super(result)
        else
          super(to_s)
        end
      end

      # @return [String]
      def to_s
        "#{input.inspect} violates constraints (#{result} failed)"
      end
    end
  end
end

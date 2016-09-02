module Dry
  module Types
    extend Dry::Configurable

    setting :namespace, self

    class SchemaError < TypeError
      def initialize(key, value)
        super("#{value.inspect} (#{value.class}) has invalid type for :#{key}")
      end
    end

    SchemaKeyError = Class.new(KeyError)
    private_constant(:SchemaKeyError)

    class MissingKeyError < SchemaKeyError
      def initialize(key)
        super(":#{key} is missing in Hash input")
      end
    end

    class UnknownKeysError < SchemaKeyError
      def initialize(*keys)
        super("unexpected keys #{keys.inspect} in Hash input")
      end
    end

    ConstraintError = Class.new(TypeError) do
      attr_reader :result, :input

      def initialize(result, input)
        @result = result
        @input = input

        if result.is_a?(String)
          super(result)
        else
          super(to_s)
        end
      end

      def to_s
        "#{input.inspect} violates constraints (#{result} failed)"
      end
    end
  end
end

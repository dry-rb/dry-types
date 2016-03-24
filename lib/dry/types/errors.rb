module Dry
  module Types
    extend Dry::Configurable

    setting :namespace, self

    class SchemaError < TypeError
      def initialize(key, value)
        super("#{value.inspect} (#{value.class}) has invalid type for :#{key}")
      end
    end

    class SchemaKeyError < KeyError
      def initialize(key)
        super(":#{key} is missing in Hash input")
      end
    end

    StructError = Class.new(TypeError)

    ConstraintError = Class.new(TypeError) do
      attr_reader :result

      def initialize(result)
        if result.is_a?(String)
          super
        else
          super("#{result.input.inspect} violates constraints (#{result.inspect})")
        end
        @result = result
      end

      def input
        result.input
      end
    end
  end
end

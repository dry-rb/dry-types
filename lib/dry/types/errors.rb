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
        @result = result
        if result.is_a?(String)
          super
        else
          super("#{result.input.inspect} violates constraints (#{failure_message})")
        end
      end

      def input
        result.input
      end

      def failure_message
        if result.respond_to?(:rule)
          rule = result.rule
          "#{rule.predicate.id}(#{rule.predicate.args.map(&:inspect).join(', ')}) failed"
        else
          result.inspect
        end
      end
    end
  end
end

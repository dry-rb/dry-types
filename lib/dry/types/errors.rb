module Dry
  module Types
    extend Dry::Core::ClassAttributes

    # @!attribute [r] namespace
    #   @return [Container{String => Nominal}]
    defines :namespace

    namespace self

    class CoercionError < StandardError
      def self.handle(error, &block)
        if block_given?
          yield
        else
          raise self[error]
        end
      end

      def self.[](error)
        case error
        when self
          error
        when ::String
          new(error)
        when ::Exception
          new(error.message, error.backtrace)
        when Result::Failure
          self[error.error]
        when ::Array
          new(error.join(', '))
        when ::Hash
          errors = error.
                     select { |_, v| v.failure? }.
                     map { |k, v| "#{ k.inspect } => #{ v.error.message }" }
          new("{#{ errors.join(', ') }}")
        else
          raise ArgumentError, "unsupported type #{ error.inspect }"
        end
      end

      def initialize(message, backtrace = nil)
        super(message)
        set_backtrace(backtrace) if backtrace
      end
    end

    class SchemaError < CoercionError
      # @param [String,Symbol] key
      # @param [Object] value
      # @param [String, #to_s] result
      def initialize(key, value, result)
        super("#{value.inspect} (#{value.class}) has invalid type for :#{key} violates constraints (#{result} failed)")
      end
    end

    MapError = Class.new(CoercionError)

    SchemaKeyError = Class.new(CoercionError)
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

    class ConstraintError < CoercionError
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

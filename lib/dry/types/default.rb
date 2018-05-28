require 'dry/types/decorator'

module Dry
  module Types
    class Default
      include Type
      include Dry::Equalizer(:type, :options, :value)
      include Decorator
      include Builder

      class Callable < Default
        include Dry::Equalizer(:type, :options)

        # Evaluates given callable
        # @return [Object]
        def evaluate
          value.call(type)
        end
      end

      # @return [Object]
      attr_reader :value

      alias_method :evaluate, :value

      # @param [Object, #call] value
      # @return [Class] {Default} or {Default::Callable}
      def self.[](value)
        if value.respond_to?(:call)
          Callable
        else
          self
        end
      end

      # @param [Type] type
      # @param [Object] value
      def initialize(type, value, **options)
        super
        @value = value
      end

      # @param [Array] args see {Dry::Types::Builder#constrained}
      # @return [Default]
      def constrained(*args)
        type.constrained(*args).default(value)
      end

      # @return [true]
      def default?
        true
      end

      # @param [Object] input
      # @return [Result::Success]
      def try(input)
        success(call(input))
      end

      def valid?(value = Undefined)
        value.equal?(Undefined) || super
      end

      # @param [Object] input
      # @return [Object] value passed through {#type} or {#default} value
      def call(input = Undefined)
        if input.equal?(Undefined)
          evaluate
        else
          output = type[input]
          output.nil? ? evaluate : output
        end
      end
      alias_method :[], :call

      private

      # Replace underlying type
      def __new__(type)
        self.class.new(type, value, options)
      end
    end
  end
end

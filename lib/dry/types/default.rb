require 'dry/types/decorator'

module Dry
  module Types
    class Default
      include Dry::Equalizer(:type, :options, :value)
      include Decorator
      include Builder

      class Callable < Default
        include Dry::Equalizer(:type, :options)

        # Evaluates given callable
        # @return [Object]
        def evaluate
          value.call
        end
      end

      # @return [Object]
      attr_reader :value

      def evaluate
        value.dup
      rescue
        value
      end

      # @param [Object, #call] value
      # @return [Default, Dry::Types::Default::Callable]
      def self.[](value)
        if value.respond_to?(:call)
          Callable
        else
          self
        end
      end

      # @param [Definition] type
      # @param [Object] value
      def initialize(type, value, *)
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
      # @return [Success]
      def try(input)
        success(call(input))
      end

      # @param [Object] input
      # @return [Object] value passed through {#type} or {#default} value
      def call(input)
        if input.nil?
          evaluate
        else
          output = type[input]
          output.nil? ? evaluate : output
        end
      end
      alias_method :[], :call
    end
  end
end

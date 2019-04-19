# frozen_string_literal: true

require 'dry/types/decorator'

module Dry
  module Types
    class Default
      class Callable < Default
        include Dry::Equalizer(:type, inspect: false)

        # Evaluates given callable
        # @return [Object]
        def evaluate
          value.call(type)
        end
      end

      include Type
      include Decorator
      include Builder
      include Printable
      include Dry::Equalizer(:type, :value, inspect: false)

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

      # @return [Boolean]
      def valid?(value = Undefined)
        Undefined.equal?(value) || super
      end

      # @api private
      #
      # @param [Object] input
      # @return [Object] value passed through {#type} or {#default} value
      def call_unsafe(input = Undefined)
        if input.equal?(Undefined)
          evaluate
        else
          Undefined.default(type.call_unsafe(input)) { evaluate }
        end
      end

      # @api pribate
      #
      # @param [Object] input
      # @return [Object] value passed through {#type} or {#default} value
      def call_safe(input = Undefined, &block)
        if input.equal?(Undefined)
          evaluate
        else
          Undefined.default(type.call_safe(input, &block)) { evaluate }
        end
      end
    end
  end
end

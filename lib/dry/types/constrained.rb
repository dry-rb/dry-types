# frozen_string_literal: true

require 'dry/types/decorator'
require 'dry/types/constraints'
require 'dry/types/constrained/coercible'

module Dry
  module Types
    class Constrained
      include Type
      include Decorator
      include Builder
      include Printable
      include Dry::Equalizer(:type, :rule, inspect: false)

      # @return [Dry::Logic::Rule]
      attr_reader :rule

      # @param [Type] type
      # @param [Hash] options
      def initialize(type, options)
        super
        @rule = options.fetch(:rule)
      end

      # @api private
      # @return [Object]
      def call_unsafe(input)
        result = rule.(input)

        if result.success?
          type.call_unsafe(input)
        else
          raise ConstraintError.new(result, input)
        end
      end

      # @api private
      # @return [Object]
      def call_safe(input, &block)
        if rule[input]
          type.call_safe(input, &block)
        else
          yield
        end
      end

      # Safe coercion attempt. It is similar to #call with a
      # block given but returns a Result instance with metadata
      # about errors (if any).
      #
      # @overload try(input)
      #   @param [Object] input
      #   @return [Logic::Result]
      #
      # @overload try(input)
      #   @param [Object] input
      #   @yieldparam [Failure] failure
      #   @yieldreturn [Object]
      #   @return [Object]
      #
      def try(input, &block)
        result = rule.(input)

        if result.success?
          type.try(input, &block)
        else
          failure = failure(input, ConstraintError.new(result, input))
          block_given? ? yield(failure) : failure
        end
      end

      # @param [Hash] options
      #   The options hash provided to {Types.Rule} and combined
      #   using {&} with previous {#rule}
      # @return [Constrained]
      # @see Dry::Logic::Operators#and
      def constrained(options)
        with(rule: rule & Types.Rule(options))
      end

      # @return [true]
      def constrained?
        true
      end

      # @param [Object] value
      # @return [Boolean]
      def ===(value)
        valid?(value)
      end

      # Build lax type. Constraints are not applicable to lax types hence unwrapping
      #
      # @return [Lax]
      def lax
        type.lax
      end

      # @see Nominal#to_ast
      def to_ast(meta: true)
        [:constrained, [type.to_ast(meta: meta), rule.to_ast]]
      end

      private

      # @param [Object] response
      # @return [Boolean]
      def decorate?(response)
        super || response.is_a?(Constructor)
      end
    end
  end
end
